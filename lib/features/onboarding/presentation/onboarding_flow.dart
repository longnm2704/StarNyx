import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/usecases/domain_usecases.dart';
import 'package:starnyx/features/onboarding/domain/create_onboarding_habits.dart';
import 'package:starnyx/features/onboarding/domain/onboarding_template.dart';
import 'package:starnyx/features/onboarding/presentation/pages/onboarding_complete_page.dart';
import 'package:starnyx/features/onboarding/presentation/pages/onboarding_reminder_page.dart';
import 'package:starnyx/features/onboarding/presentation/pages/onboarding_template_picker_page.dart';
import 'package:starnyx/features/onboarding/presentation/pages/onboarding_welcome_page.dart';
import 'package:starnyx/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:starnyx/features/settings/presentation/pages/backup_page.dart';
import 'package:starnyx/features/starnyx_form/presentation/pages/starnyx_form_page.dart';

/// First-run onboarding: welcome (U020) → template picker (U021) → reminder
/// setup (U022) → completion (U023).
///
/// Mount it from the app root (STX-U024). The flow owns a nested [Navigator],
/// so every onboarding route goes away when this widget is unmounted.
/// [onFinished] fires once the user leaves onboarding: skipped, restored a
/// backup, saved a custom habit, or completed the flow.
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({required this.onFinished, super.key});

  final VoidCallback onFinished;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _navigatorKey.currentState!;

  void _openTemplatePicker() {
    _navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => OnboardingTemplatePickerPage(
          onBack: _navigator.pop,
          onSkip: widget.onFinished,
          onCreateCustom: _createCustomHabit,
          onContinue: _openReminderSetup,
        ),
      ),
    );
  }

  void _openReminderSetup(List<OnboardingTemplate> templates) {
    _navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => OnboardingReminderPage(
          templates: templates,
          onBack: _navigator.pop,
          onSkip: widget.onFinished,
          onStart: _createHabits,
        ),
      ),
    );
  }

  // Throws on failure (after rolling back); the reminder page shows the error.
  Future<void> _createHabits(List<OnboardingHabitDraft> drafts) async {
    final habits = await createOnboardingHabits(
      drafts,
      create: serviceLocator<CreateStarNyxUseCase>(),
      delete: serviceLocator<DeleteStarNyxUseCase>(),
      sync: serviceLocator<SyncNotificationsUseCase>(),
    );
    unawaited(_openCompletion(habits));
  }

  Future<void> _openCompletion(List<StarNyx> habits) async {
    var done = false;
    await _navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => OnboardingCompletePage(
          habits: habits,
          onBack: _navigator.pop,
          onDone: () {
            done = true;
            widget.onFinished();
          },
        ),
      ),
    );
    if (done) return;
    // Backing out to the reminder step undoes the creation, so pressing its
    // CTA again does not duplicate the habits.
    await deleteOnboardingHabits(
      habits,
      delete: serviceLocator<DeleteStarNyxUseCase>(),
      sync: serviceLocator<SyncNotificationsUseCase>(),
    );
  }

  Future<void> _createCustomHabit() async {
    final result = await StarnyxFormPage.open(_navigatorKey.currentContext!);
    if (result?.savedStarnyx != null) widget.onFinished();
  }

  // Only an import finishes onboarding; a delete-all leaves it running.
  Future<void> _restore() async {
    final outcome = await _navigator.push<BackupOutcome>(
      MaterialPageRoute<BackupOutcome>(
        builder: (routeContext) => BlocProvider<SettingsBloc>(
          create: (_) => serviceLocator<SettingsBloc>(),
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: BackupPage(onBack: () => Navigator.of(routeContext).pop()),
          ),
        ),
      ),
    );
    if (outcome == BackupOutcome.imported) widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    return NavigatorPopHandler<Object?>(
      onPopWithResult: (_) => _navigator.maybePop(),
      child: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          builder: (_) => OnboardingWelcomePage(
            onStart: _openTemplatePicker,
            // Skip leaves onboarding with no habits (empty Habits tab).
            onSkip: widget.onFinished,
            onRestore: _restore,
          ),
        ),
      ),
    );
  }
}

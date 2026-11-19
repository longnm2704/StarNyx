import 'package:flutter/material.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:starnyx/app/shell/app_shell.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/services/core_services.dart';
import 'package:starnyx/domain/usecases/domain_usecases.dart';
import 'package:starnyx/features/onboarding/presentation/onboarding_flow.dart';

/// Chooses between first-run onboarding and the app shell (STX-U024).
///
/// Onboarding shows only when the flag is unset AND there are no habits, so
/// existing users never see it. Every onboarding exit sets the flag;
/// delete-all clears it and [AppShell.onDataReplaced] re-runs the check.
class AppRoot extends StatefulWidget {
  const AppRoot({
    this.initialTab = AppShellTab.habits,
    this.initialAccentColor,
    this.tabs,
    super.key,
  });

  final AppShellTab initialTab;
  final Color? initialAccentColor;

  /// Forwarded to [AppShell.tabs] (tests).
  final List<Widget>? tabs;

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  final _onboarding = serviceLocator<OnboardingPreferences>();

  /// null while the first check is running.
  bool? _showOnboarding;

  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    final completed = _onboarding.completed;
    final hasHabits =
        (await serviceLocator<LoadStarnyxsUseCase>()()).isNotEmpty;
    // Users who had habits before onboarding existed count as onboarded, so
    // deleting their habits one by one never brings onboarding back.
    if (hasHabits && !completed) await _onboarding.setCompleted(true);
    if (mounted) setState(() => _showOnboarding = !completed && !hasHabits);
  }

  Future<void> _finishOnboarding() async {
    await _onboarding.setCompleted(true);
    if (mounted) setState(() => _showOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    return switch (_showOnboarding) {
      null => const ColoredBox(color: AppColors.background),
      true => OnboardingFlow(onFinished: _finishOnboarding),
      false => AppShell(
        initialTab: widget.initialTab,
        initialAccentColor: widget.initialAccentColor,
        tabs: widget.tabs,
        onDataReplaced: _route,
      ),
    };
  }
}

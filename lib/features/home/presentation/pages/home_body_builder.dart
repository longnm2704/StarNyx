import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/features/home/presentation/bloc/home_state.dart';
import 'package:starnyx/features/home/presentation/widgets/home_widgets.dart';

import 'home_screen_switcher.dart';

/// Reads [HomeState] and renders the correct full-screen child widget:
///
/// - [HomeStatus.initial] / [HomeStatus.loading] → [HomeLoadingView]
/// - [HomeStatus.failure]                        → [HomeErrorView]
/// - loaded + empty list                         → [AppEmptyState] with a
///   create CTA (first run goes through onboarding; this is for users who
///   skipped it or deleted every habit)
/// - loaded + non-empty list                     → [ActiveStarnyxHomeView]
///
/// Passes the chosen child to [HomeScreenSwitcher] so transitions are always
/// smooth regardless of which state change triggered the rebuild.
class HomeBodyBuilder extends StatelessWidget {
  const HomeBodyBuilder({
    required this.state,
    required this.accentColor,
    required this.onRetry,
    required this.onCreatePressed,
    required this.onSettingsPressed,
    required this.onDateSelected,
    required this.onPreviousDayPressed,
    required this.onNextDayPressed,
    required this.onJumpToTodayPressed,
    required this.onPreviousYearPressed,
    required this.onNextYearPressed,
    required this.onProfilePressed,
    required this.onSearchPressed,
    required this.onToggleCompletionPressed,
    super.key,
  });

  final HomeState state;

  /// Resolved accent colour for the active StarNyx, or a cached / fallback
  /// value so the loading shimmer always has something to render with.
  final Color accentColor;

  // ── Callbacks forwarded to child views ────────────────────────────────────

  final VoidCallback onRetry;
  final FutureOr<void> Function()? onCreatePressed;
  final VoidCallback? onSettingsPressed;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onPreviousDayPressed;
  final VoidCallback onNextDayPressed;
  final VoidCallback onJumpToTodayPressed;
  final VoidCallback onPreviousYearPressed;
  final VoidCallback onNextYearPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onSearchPressed;
  final VoidCallback onToggleCompletionPressed;

  @override
  Widget build(BuildContext context) {
    return HomeScreenSwitcher(child: _resolveChild());
  }

  Widget _resolveChild() {
    if (state.status == HomeStatus.initial ||
        state.status == HomeStatus.loading) {
      // Always show HomeLoadingView (use a neutral fallback when no accent
      // color is cached yet) to avoid an extra animated hop from a blank
      // ColoredBox → LoadingView → ActiveView.
      return HomeLoadingView(
        key: const ValueKey<String>('loading_view'),
        accentColor: accentColor,
      );
    }

    if (state.status == HomeStatus.failure) {
      return HomeErrorView(
        key: const ValueKey<String>('error_view'),
        onRetry: onRetry,
        accentColor: accentColor,
      );
    }

    if (state.starnyxs.isEmpty) {
      return SafeArea(
        key: const ValueKey<String>('empty_view'),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
            child: AppEmptyState(
              title: 'habits.empty_title'.tr(),
              message: 'habits.empty_message'.tr(),
              actionLabel: 'habits.empty_action'.tr(),
              onActionPressed: () => onCreatePressed?.call(),
            ),
          ),
        ),
      );
    }

    return ActiveStarnyxHomeView(
      key: const ValueKey<String>('active_view'),
      activeStarnyx: _resolveActiveStarnyx(),
      selectedDate: state.selectedDate,
      todayDate: DateTime.now(),
      viewedYear: state.viewedYear,
      completedDatesForViewedYear: state.completedDatesForViewedYear,
      onDateSelected: onDateSelected,
      onPreviousDayPressed: onPreviousDayPressed,
      onNextDayPressed: onNextDayPressed,
      onJumpToTodayPressed: onJumpToTodayPressed,
      onPreviousYearPressed: onPreviousYearPressed,
      onNextYearPressed: onNextYearPressed,
      onProfilePressed: onProfilePressed,
      onSearchPressed: onSearchPressed,
      onToggleCompletionPressed: onToggleCompletionPressed,
      isCheckingIn: state.completionStatus == AsyncStatus.inProgress,
      completionSuccessAnimationToken:
          state.completionStatus == AsyncStatus.success
          ? state.completionFeedbackCount
          : null,
      progressStats: state.progressStats,
    );
  }

  StarNyx _resolveActiveStarnyx() {
    final activeId = state.activeStarnyxId;
    if (activeId == null) {
      return state.starnyxs.first;
    }
    return state.starnyxs.firstWhere(
      (starnyx) => starnyx.id == activeId,
      orElse: () => state.starnyxs.first,
    );
  }
}

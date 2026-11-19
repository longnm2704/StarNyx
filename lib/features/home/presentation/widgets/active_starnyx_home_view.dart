import 'package:flutter/material.dart';
import 'package:starnyx/core/utils/date_utils.dart' as core_date_utils;
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/entities/starnyx_progress_stats.dart';

import 'home_shell_view.dart';

bool canToggleCompletionForSelectedDate({
  required DateTime selectedDate,
  required DateTime todayDate,
  required DateTime startDate,
}) {
  if (core_date_utils.DateUtils.isFutureDate(selectedDate, today: todayDate)) {
    return false;
  }
  if (core_date_utils.DateUtils.isBeforeStartDate(
    selectedDate,
    startDate: startDate,
  )) {
    return false;
  }
  return core_date_utils.DateUtils.isEditableWithinDays(
    selectedDate,
    days: 7,
    today: todayDate,
  );
}

class ActiveStarnyxHomeView extends StatelessWidget {
  const ActiveStarnyxHomeView({
    required this.activeStarnyx,
    required this.selectedDate,
    required this.todayDate,
    required this.viewedYear,
    required this.completedDatesForViewedYear,
    required this.onDateSelected,
    required this.onPreviousDayPressed,
    required this.onNextDayPressed,
    required this.onJumpToTodayPressed,
    required this.onPreviousYearPressed,
    required this.onNextYearPressed,
    required this.onProfilePressed,
    required this.onToggleCompletionPressed,
    required this.isCheckingIn,
    this.completionSuccessAnimationToken,
    this.progressStats,
    super.key,
  });

  final StarNyx activeStarnyx;
  final DateTime selectedDate;
  final DateTime todayDate;
  final int viewedYear;
  final List<DateTime> completedDatesForViewedYear;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onPreviousDayPressed;
  final VoidCallback onNextDayPressed;
  final VoidCallback onJumpToTodayPressed;
  final VoidCallback onPreviousYearPressed;
  final VoidCallback onNextYearPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback onToggleCompletionPressed;
  final bool isCheckingIn;
  final int? completionSuccessAnimationToken;
  final StarNyxProgressStats? progressStats;

  @override
  Widget build(BuildContext context) {
    final canToggleCompletion = canToggleCompletionForSelectedDate(
      selectedDate: selectedDate,
      todayDate: todayDate,
      startDate: activeStarnyx.startDate,
    );
    final canMoveToNextYear = viewedYear < todayDate.year;

    return HomeShellView(
      activeStarnyx: activeStarnyx,
      selectedDate: selectedDate,
      todayDate: todayDate,
      viewedYear: viewedYear,
      completedDatesForViewedYear: completedDatesForViewedYear,
      progressStats: progressStats,
      onPreviousDayPressed: onPreviousDayPressed,
      onNextDayPressed: onNextDayPressed,
      onJumpToTodayPressed: onJumpToTodayPressed,
      onDateSelected: onDateSelected,
      onPreviousYearPressed: onPreviousYearPressed,
      onNextYearPressed: canMoveToNextYear ? onNextYearPressed : null,
      onProfilePressed: onProfilePressed,
      onToggleCompletionPressed: canToggleCompletion
          ? onToggleCompletionPressed
          : null,
      isCheckingIn: isCheckingIn,
      completionSuccessAnimationToken: completionSuccessAnimationToken,
    );
  }
}

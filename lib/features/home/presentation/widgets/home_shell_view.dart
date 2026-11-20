import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/app_icon.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/entities/starnyx_progress_stats.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_color_utils.dart';

import 'home_app_bar.dart';
import 'home_star_grid.dart';
import 'selected_date_bar.dart';
import 'home_year_summary_row.dart';

export 'home_grid_utils.dart'
    show homeGridColumnCount, homeGridDateForIndex, homeGridDayCountForYear;

Color homeShellAccentColor(String starnyxHex) {
  return starnyxColorFromHex(starnyxHex);
}

int homeShellDaysLeftInViewedYear({
  required int viewedYear,
  required DateTime todayDate,
}) {
  final normalizedToday = DateTime.utc(
    todayDate.year,
    todayDate.month,
    todayDate.day,
  );
  final yearEnd = DateTime.utc(viewedYear + 1, 1, 1);
  final diff = yearEnd.difference(normalizedToday).inDays;
  return diff < 0 ? 0 : diff;
}

class HomeShellView extends StatelessWidget {
  const HomeShellView({
    required this.activeStarnyx,
    required this.selectedDate,
    required this.todayDate,
    required this.viewedYear,
    required this.completedDatesForViewedYear,
    required this.progressStats,
    required this.onPreviousDayPressed,
    required this.onNextDayPressed,
    required this.onJumpToTodayPressed,
    required this.onDateSelected,
    required this.onPreviousYearPressed,
    required this.onNextYearPressed,
    required this.onProfilePressed,
    this.onSearchPressed,
    this.onToggleCompletionPressed,
    this.isCheckingIn = false,
    this.completionSuccessAnimationToken,
    this.checkInBlockedReasonKey,
    super.key,
  });

  final StarNyx activeStarnyx;
  final DateTime selectedDate;
  final DateTime todayDate;
  final int viewedYear;
  final List<DateTime> completedDatesForViewedYear;
  final StarNyxProgressStats? progressStats;
  final VoidCallback? onPreviousDayPressed;
  final VoidCallback? onNextDayPressed;
  final VoidCallback? onJumpToTodayPressed;
  final ValueChanged<DateTime>? onDateSelected;
  final VoidCallback? onPreviousYearPressed;
  final VoidCallback? onNextYearPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onToggleCompletionPressed;
  final bool isCheckingIn;
  final int? completionSuccessAnimationToken;

  /// Why check-in is disabled for the selected day (translation key).
  final String? checkInBlockedReasonKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localeTag = context.locale.toLanguageTag();
    final selectedDateLabel = DateFormat(
      'EEEE, d MMM',
      localeTag,
    ).format(selectedDate);
    final daysLeft = homeShellDaysLeftInViewedYear(
      viewedYear: viewedYear,
      todayDate: todayDate,
    );
    final totalCompleted = progressStats?.totalCompletedCount ?? 0;
    final currentStreak = progressStats?.currentStreak ?? 0;
    final longestStreak = progressStats?.longestStreak ?? 0;
    final completionRateForYear = progressStats?.completionRateForYear ?? 0.0;
    final accentColor = homeShellAccentColor(activeStarnyx.color);
    final normalizedSelected = DateTime.utc(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final isLit = completedDatesForViewedYear.any(
      (completed) =>
          DateTime.utc(completed.year, completed.month, completed.day) ==
          normalizedSelected,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.82),
          radius: 1.08,
          colors: <Color>[
            accentColor.withValues(alpha: 0.16),
            AppColors.background,
          ],
          stops: const <double>[0.0, 0.68],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  HomeAppBar(
                    onProfilePressed: onProfilePressed,
                    onSearchPressed: onSearchPressed,
                  ),
                  _Header(
                    activeStarnyx: activeStarnyx,
                    accentColor: accentColor,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLevel1,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(color: AppColors.borderSubtle),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.6),
                            blurRadius: 32,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: HomeStarGrid(
                        viewedYear: viewedYear,
                        selectedDate: selectedDate,
                        todayDate: todayDate,
                        startDate: activeStarnyx.startDate,
                        completedDatesForViewedYear:
                            completedDatesForViewedYear,
                        accentColor: accentColor,
                        symbolKey: activeStarnyx.icon,
                        onDateSelected: onDateSelected,
                        completionSuccessAnimationToken:
                            completionSuccessAnimationToken,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  HomeYearSummaryRow(
                    viewedYear: viewedYear,
                    daysLeft: daysLeft,
                    accentColor: accentColor,
                    onPreviousYearPressed: onPreviousYearPressed,
                    onNextYearPressed: onNextYearPressed,
                    onJumpToTodayPressed: onJumpToTodayPressed,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal,
                    ),
                    child: SelectedDateBar(
                      selectedDateLabel: selectedDateLabel,
                      onPreviousDayPressed: onPreviousDayPressed,
                      onNextDayPressed: onNextDayPressed,
                      accentColor: accentColor,
                      symbolKey: activeStarnyx.icon,
                      isLit: isLit,
                      onSelectedDatePressed: onToggleCompletionPressed,
                      isCheckingIn: isCheckingIn,
                      isToday:
                          selectedDate.year == todayDate.year &&
                          selectedDate.month == todayDate.month &&
                          selectedDate.day == todayDate.day,
                      blockedReason: checkInBlockedReasonKey?.tr(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal,
                    ),
                    child: _StatsPill(
                      totalCompleted: totalCompleted,
                      currentStreak: currentStreak,
                      longestStreak: longestStreak,
                      completionRate: completionRateForYear,
                      accentColor: accentColor,
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.activeStarnyx, required this.accentColor});

  final StarNyx activeStarnyx;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.md,
        AppSpacing.pageHorizontal,
        AppSpacing.lg,
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceLevel1,
              border: Border.all(color: accentColor.withValues(alpha: 0.22)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.35),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: AppIcon(
                icon: HabitSymbols.iconFor(activeStarnyx.icon),
                color: accentColor,
                size: 30,
                strokeWidth: 2,
                semanticsLabel: 'home.header_semantics'.tr(
                  args: <String>[activeStarnyx.title],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            activeStarnyx.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (activeStarnyx.hasDescription) ...<Widget>[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              activeStarnyx.description!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: accentColor.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatsPill extends StatelessWidget {
  const _StatsPill({
    required this.totalCompleted,
    required this.currentStreak,
    required this.longestStreak,
    required this.completionRate,
    required this.accentColor,
    required this.style,
  });

  final int totalCompleted;
  final int currentStreak;
  final int longestStreak;
  final double completionRate;
  final Color accentColor;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final baseStyle = style?.copyWith(
      height: 16 / 12,
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w500,
    );
    final rateStyle = baseStyle?.copyWith(
      color: accentColor,
      fontWeight: FontWeight.w700,
    );
    final separator = Text('·', style: baseStyle);

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceLevel1.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.xs,
          runSpacing: 2,
          children: <Widget>[
            Text(
              'home.stats_days_lit'.plural(totalCompleted),
              style: baseStyle,
            ),
            separator,
            Text(
              'home.stats_streak'.tr(args: <String>[currentStreak.toString()]),
              style: baseStyle,
            ),
            separator,
            Text(
              'home.stats_best'.tr(args: <String>[longestStreak.toString()]),
              style: baseStyle,
            ),
            separator,
            Text(
              'home.stats_rate'.tr(
                args: <String>[(completionRate * 100).round().toString()],
              ),
              style: rateStyle,
            ),
          ],
        ),
      ),
    );
  }
}

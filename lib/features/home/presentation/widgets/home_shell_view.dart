import 'package:flutter/material.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/domain/entities/starnyx_progress_stats.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_color_utils.dart';

import 'home_star_grid.dart';
import 'selected_date_bar.dart';
import 'home_year_summary_row.dart';

export 'home_grid_utils.dart'
    show homeGridColumnCount, homeGridDateForIndex, homeGridDayCountForYear;

List<Color> homeShellGradientColors(String starnyxHex) {
  final Color accent = starnyxColorFromHex(starnyxHex);
  return <Color>[
    Color.lerp(accent, AppColors.black, 0.18)!,
    Color.lerp(accent, AppColors.black, 0.52)!,
    Color.lerp(accent, AppColors.black, 0.88)!,
    AppColors.black,
  ];
}

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
    required this.onQuickActionsPressed,
    this.onToggleCompletionPressed,
    this.isCheckingIn = false,
    this.footer,
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
  final VoidCallback? onQuickActionsPressed;
  final VoidCallback? onToggleCompletionPressed;
  final bool isCheckingIn;
  final Widget? footer;

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
    final gradientColors = homeShellGradientColors(activeStarnyx.color);
    final accentColor = homeShellAccentColor(activeStarnyx.color);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
          stops: const <double>[0.0, 0.26, 0.54, 1.0],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.82),
                  radius: 1.02,
                  colors: <Color>[
                    accentColor.withValues(alpha: 0.24),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppLayout.contentMaxWidth,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.md,
                    AppSpacing.pageHorizontal,
                    0,
                  ),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        activeStarnyx.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                          letterSpacing: -0.7,
                        ),
                      ),
                      if ((activeStarnyx.description ?? '')
                          .trim()
                          .isNotEmpty) ...<Widget>[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          activeStarnyx.description!,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      Expanded(
                        child: HomeStarGrid(
                          viewedYear: viewedYear,
                          selectedDate: selectedDate,
                          todayDate: todayDate,
                          startDate: activeStarnyx.startDate,
                          completedDatesForViewedYear:
                              completedDatesForViewedYear,
                          accentColor: accentColor,
                          onDateSelected: onDateSelected,
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
                      SelectedDateBar(
                        selectedDateLabel: selectedDateLabel,
                        onPreviousDayPressed: onPreviousDayPressed,
                        onNextDayPressed: onNextDayPressed,
                        accentColor: accentColor,
                        onSelectedDatePressed: onToggleCompletionPressed,
                        isCheckingIn: isCheckingIn,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'home.summary_stats'.tr(
                          args: <String>[
                            totalCompleted.toString(),
                            currentStreak.toString(),
                          ],
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary.withValues(alpha: 0.64),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (footer != null) ...<Widget>[
                        const SizedBox(height: AppSpacing.xxs),
                        footer!,
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

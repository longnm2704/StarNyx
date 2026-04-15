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
    required this.onYearPressed,
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
  final VoidCallback? onYearPressed;
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
    final daysLeft = DateTime.utc(viewedYear + 1, 1, 1)
        .difference(
          DateTime.utc(selectedDate.year, selectedDate.month, selectedDate.day),
        )
        .inDays;
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
                    AppSpacing.sm,
                    AppSpacing.pageHorizontal,
                    AppSpacing.sm,
                  ),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 8),
                      Text(
                        activeStarnyx.title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 24,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if ((activeStarnyx.description ?? '')
                          .trim()
                          .isNotEmpty) ...<Widget>[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          activeStarnyx.description!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary.withValues(
                              alpha: 0.62,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
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
                        onYearPressed: onYearPressed,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      GestureDetector(
                        onTap: onJumpToTodayPressed,
                        child: Text(
                          'home.reset_current_date'.tr(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: accentColor.withValues(alpha: 0.95),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
                          color: AppColors.textPrimary.withValues(alpha: 0.58),
                          fontWeight: FontWeight.w700,
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

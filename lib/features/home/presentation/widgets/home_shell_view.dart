import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/app_svg_icon.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/entities/starnyx_progress_stats.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_color_utils.dart';

int homeGridDayCountForYear(int year) {
  return DateTime.utc(
    year + 1,
    1,
    1,
  ).difference(DateTime.utc(year, 1, 1)).inDays;
}

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
    required this.onYearPressed,
    required this.onQuickActionsPressed,
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
  final VoidCallback? onYearPressed;
  final VoidCallback? onQuickActionsPressed;
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
          stops: <double>[0.0, 0.26, 0.54, 1.0],
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
                        child: _HomeStarGridPlaceholder(
                          viewedYear: viewedYear,
                          selectedDate: selectedDate,
                          todayDate: todayDate,
                          completedDatesForViewedYear:
                              completedDatesForViewedYear,
                          accentColor: accentColor,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _HomeYearSummaryRow(
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
                      _SelectedDateBar(
                        selectedDateLabel: selectedDateLabel,
                        onPreviousDayPressed: onPreviousDayPressed,
                        onNextDayPressed: onNextDayPressed,
                        accentColor: accentColor,
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

class _HomeStarGridPlaceholder extends StatelessWidget {
  const _HomeStarGridPlaceholder({
    required this.viewedYear,
    required this.selectedDate,
    required this.todayDate,
    required this.completedDatesForViewedYear,
    required this.accentColor,
  });

  final int viewedYear;
  final DateTime selectedDate;
  final DateTime todayDate;
  final List<DateTime> completedDatesForViewedYear;
  final Color accentColor;

  static const int _columnCount = 18;
  static const double _gridSpacing = 4;

  @override
  Widget build(BuildContext context) {
    final int daysInYear = homeGridDayCountForYear(viewedYear);
    final DateTime normalizedSelectedDate = DateTime.utc(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final DateTime normalizedTodayDate = DateTime.utc(
      todayDate.year,
      todayDate.month,
      todayDate.day,
    );
    final Set<int> completedDayIndexes = completedDatesForViewedYear
        .map((DateTime date) => _dayOfYear(date) - 1)
        .toSet();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double horizontalSpacing = (_columnCount - 1) * _gridSpacing;
        final double cellExtent =
            (constraints.maxWidth - horizontalSpacing) / _columnCount;
        final double effectiveCellExtent = math.max(8, cellExtent);

        return GridView.builder(
          key: const Key('home-star-grid-placeholder'),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _columnCount,
            crossAxisSpacing: _gridSpacing,
            mainAxisSpacing: _gridSpacing,
            mainAxisExtent: effectiveCellExtent,
          ),
          itemCount: daysInYear,
          itemBuilder: (BuildContext context, int index) {
            final DateTime date = DateTime.utc(
              viewedYear,
              1,
              1,
            ).add(Duration(days: index));
            final bool isSelected = _isSameDate(date, normalizedSelectedDate);
            final bool isToday = _isSameDate(date, normalizedTodayDate);
            final bool isCompleted = completedDayIndexes.contains(index);

            return KeyedSubtree(
              key: index == 0
                  ? ValueKey<String>('home-star-grid-day-count-$daysInYear')
                  : null,
              child: _GridStarCell(
                key: ValueKey<String>('home-star-cell-$index'),
                size: effectiveCellExtent,
                isCompleted: isCompleted,
                isSelected: isSelected,
                isToday: isToday,
                accentColor: accentColor,
                selectedKey: isSelected
                    ? const Key('home-selected-star-cell')
                    : null,
                completedKey: isCompleted
                    ? Key('home-completed-star-cell-$index')
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  int _dayOfYear(DateTime date) {
    return DateTime.utc(
          date.year,
          date.month,
          date.day,
        ).difference(DateTime.utc(date.year, 1, 1)).inDays +
        1;
  }

  bool _isSameDate(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}

class _GridStarCell extends StatelessWidget {
  const _GridStarCell({
    required this.size,
    required this.isCompleted,
    required this.isSelected,
    required this.isToday,
    required this.accentColor,
    super.key,
    this.selectedKey,
    this.completedKey,
  });

  final double size;
  final bool isCompleted;
  final bool isSelected;
  final bool isToday;
  final Color accentColor;
  final Key? selectedKey;
  final Key? completedKey;

  @override
  Widget build(BuildContext context) {
    final double iconSize = isToday
        ? size * 0.94
        : isSelected
        ? size * 0.84
        : size * 0.72;

    return SizedBox(
      width: size,
      height: size,
      key: selectedKey,
      child: Container(
        key: completedKey,
        alignment: Alignment.center,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
        child: Center(
          child: AppSvgIcon(
            assetPath: isCompleted || isSelected
                ? 'assets/icons/ic_star_active.svg'
                : 'assets/icons/ic_star.svg',
            size: iconSize,
            color: isCompleted || isSelected
                ? accentColor.withValues(alpha: isSelected ? 0.98 : 0.88)
                : AppColors.white.withValues(alpha: 0.28),
          ),
        ),
      ),
    );
  }
}

class _HomeYearSummaryRow extends StatelessWidget {
  const _HomeYearSummaryRow({
    required this.viewedYear,
    required this.daysLeft,
    required this.onYearPressed,
  });

  final int viewedYear;
  final int daysLeft;
  final VoidCallback? onYearPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: <Widget>[
        InkWell(
          onTap: onYearPressed,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.chevron_left_rounded,
                  size: 18,
                  color: AppColors.textPrimary.withValues(alpha: 0.6),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  viewedYear.toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.textPrimary.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        Text(
          'home.days_left'.tr(args: <String>[daysLeft.toString()]),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary.withValues(alpha: 0.7),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SelectedDateBar extends StatelessWidget {
  const _SelectedDateBar({
    required this.selectedDateLabel,
    required this.onPreviousDayPressed,
    required this.onNextDayPressed,
    required this.accentColor,
  });

  final String selectedDateLabel;
  final VoidCallback? onPreviousDayPressed;
  final VoidCallback? onNextDayPressed;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: <Widget>[
        _DayChevronButton(
          icon: Icons.chevron_left_rounded,
          buttonKey: const Key('home-previous-day-button'),
          onPressed: onPreviousDayPressed,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color.lerp(accentColor, AppColors.black, 0.82),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: accentColor.withValues(alpha: 0.22)),
            ),
            child: Text(
              selectedDateLabel,
              style: theme.textTheme.titleMedium?.copyWith(
                color: accentColor.withValues(alpha: 0.58),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _DayChevronButton(
          icon: Icons.chevron_right_rounded,
          buttonKey: const Key('home-next-day-button'),
          onPressed: onNextDayPressed,
        ),
      ],
    );
  }
}

class _DayChevronButton extends StatelessWidget {
  const _DayChevronButton({
    required this.icon,
    required this.buttonKey,
    required this.onPressed,
  });

  final IconData icon;
  final Key buttonKey;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: buttonKey,
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: AppColors.textPrimary.withValues(
          alpha: onPressed == null ? 0.3 : 0.6,
        ),
        size: 26,
      ),
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/app_svg_icon.dart';

import 'home_grid_utils.dart';

class HomeStarGrid extends StatelessWidget {
  const HomeStarGrid({
    required this.viewedYear,
    required this.selectedDate,
    required this.todayDate,
    required this.startDate,
    required this.completedDatesForViewedYear,
    required this.accentColor,
    required this.onDateSelected,
    super.key,
  });

  final int viewedYear;
  final DateTime selectedDate;
  final DateTime todayDate;
  final DateTime startDate;
  final List<DateTime> completedDatesForViewedYear;
  final Color accentColor;
  final ValueChanged<DateTime>? onDateSelected;

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
    final DateTime normalizedStartDate = DateTime.utc(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final Set<int> completedDayIndexes = completedDatesForViewedYear
        .map((DateTime date) => _dayOfYear(date) - 1)
        .toSet();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double horizontalSpacing =
            (homeGridColumnCount - 1) * _gridSpacing;
        final double cellExtent =
            (constraints.maxWidth - horizontalSpacing) / homeGridColumnCount;
        final double effectiveCellExtent = math.max(8, cellExtent);

        return GridView.builder(
          key: const Key('home-star-grid-placeholder'),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: homeGridColumnCount,
            crossAxisSpacing: _gridSpacing,
            mainAxisSpacing: _gridSpacing,
            mainAxisExtent: effectiveCellExtent,
          ),
          itemCount: daysInYear,
          itemBuilder: (BuildContext context, int index) {
            final DateTime date = homeGridDateForIndex(viewedYear, index);
            final bool isSelected = _isSameDate(date, normalizedSelectedDate);
            final bool isToday = _isSameDate(date, normalizedTodayDate);
            final _GridStarDayState dayState = _resolveDayState(
              date: date,
              startDate: normalizedStartDate,
              todayDate: normalizedTodayDate,
              isCompleted: completedDayIndexes.contains(index),
            );
            final bool canSelectDay =
                dayState != _GridStarDayState.beforeStart &&
                dayState != _GridStarDayState.future;

            return KeyedSubtree(
              key: index == 0
                  ? ValueKey<String>('home-star-grid-day-count-$daysInYear')
                  : null,
              child: _GridStarCell(
                key: ValueKey<String>('home-star-cell-$index'),
                size: effectiveCellExtent,
                dayState: dayState,
                isSelected: isSelected,
                isToday: isToday,
                accentColor: accentColor,
                onTap: onDateSelected == null || !canSelectDay
                    ? null
                    : () => onDateSelected!(date),
                selectedKey: isSelected
                    ? const Key('home-selected-star-cell')
                    : null,
                completedKey: dayState == _GridStarDayState.completed
                    ? Key('home-completed-star-cell-$index')
                    : null,
                beforeStartKey: dayState == _GridStarDayState.beforeStart
                    ? Key('home-before-start-star-cell-$index')
                    : null,
                missedKey: dayState == _GridStarDayState.missed
                    ? Key('home-missed-star-cell-$index')
                    : null,
                futureKey: dayState == _GridStarDayState.future
                    ? Key('home-future-star-cell-$index')
                    : null,
                todayKey: isToday ? Key('home-today-star-cell-$index') : null,
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

  _GridStarDayState _resolveDayState({
    required DateTime date,
    required DateTime startDate,
    required DateTime todayDate,
    required bool isCompleted,
  }) {
    if (date.isBefore(startDate)) {
      return _GridStarDayState.beforeStart;
    }
    if (date.isAfter(todayDate)) {
      return _GridStarDayState.future;
    }
    if (isCompleted) {
      return _GridStarDayState.completed;
    }
    return _GridStarDayState.missed;
  }
}

enum _GridStarDayState { beforeStart, completed, missed, future }

class _GridStarCell extends StatelessWidget {
  const _GridStarCell({
    required this.size,
    required this.dayState,
    required this.isSelected,
    required this.isToday,
    required this.accentColor,
    required this.onTap,
    super.key,
    this.selectedKey,
    this.completedKey,
    this.beforeStartKey,
    this.missedKey,
    this.futureKey,
    this.todayKey,
  });

  final double size;
  final _GridStarDayState dayState;
  final bool isSelected;
  final bool isToday;
  final Color accentColor;
  final VoidCallback? onTap;
  final Key? selectedKey;
  final Key? completedKey;
  final Key? beforeStartKey;
  final Key? missedKey;
  final Key? futureKey;
  final Key? todayKey;

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: onTap,
          child: Container(
            key: _cellStateKey(),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? accentColor.withValues(alpha: 0.14) : null,
              borderRadius: BorderRadius.circular(4),
              border: isSelected
                  ? Border.all(color: accentColor.withValues(alpha: 0.32))
                  : null,
            ),
            child: Center(
              child: DecoratedBox(
                key: todayKey,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isToday
                      ? Border.all(
                          color: accentColor.withValues(alpha: 0.8),
                          width: 1.4,
                        )
                      : null,
                ),
                child: Padding(
                  padding: EdgeInsets.all(isToday ? 1.2 : 0),
                  child: AppSvgIcon(
                    assetPath: _starAssetPath(),
                    size: iconSize,
                    color: _starColor(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _starAssetPath() {
    switch (dayState) {
      case _GridStarDayState.beforeStart:
      case _GridStarDayState.future:
        return 'assets/icons/ic_star.svg';
      case _GridStarDayState.completed:
      case _GridStarDayState.missed:
        return 'assets/icons/ic_star_active.svg';
    }
  }

  Color _starColor() {
    if (isSelected) {
      return accentColor.withValues(alpha: 0.98);
    }
    switch (dayState) {
      case _GridStarDayState.beforeStart:
        return AppColors.white.withValues(alpha: 0.1);
      case _GridStarDayState.completed:
        return accentColor.withValues(alpha: 0.88);
      case _GridStarDayState.missed:
        return accentColor.withValues(alpha: 0.28);
      case _GridStarDayState.future:
        return AppColors.white.withValues(alpha: 0.2);
    }
  }

  Key? _cellStateKey() {
    if (completedKey != null) {
      return completedKey;
    }
    if (beforeStartKey != null) {
      return beforeStartKey;
    }
    if (missedKey != null) {
      return missedKey;
    }
    if (futureKey != null) {
      return futureKey;
    }
    return null;
  }
}

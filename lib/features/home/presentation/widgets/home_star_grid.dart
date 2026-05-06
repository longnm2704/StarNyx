import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:starnyx/core/widgets/app_svg_icon.dart';
import 'package:starnyx/core/constants/core_constants.dart';

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
    this.completionSuccessAnimationToken,
    super.key,
  });

  final int viewedYear;
  final DateTime selectedDate;
  final DateTime todayDate;
  final DateTime startDate;
  final List<DateTime> completedDatesForViewedYear;
  final Color accentColor;
  final ValueChanged<DateTime>? onDateSelected;
  final int? completionSuccessAnimationToken;

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
            final HomeGridStarDayState dayState = _resolveDayState(
              date: date,
              startDate: normalizedStartDate,
              todayDate: normalizedTodayDate,
              isCompleted: completedDayIndexes.contains(index),
            );

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
                onTap: onDateSelected == null
                    ? null
                    : () => onDateSelected!(date),
                selectedKey: isSelected
                    ? const Key('home-selected-star-cell')
                    : null,
                completedKey: dayState == HomeGridStarDayState.completed
                    ? Key('home-completed-star-cell-$index')
                    : null,
                beforeStartKey: dayState == HomeGridStarDayState.beforeStart
                    ? Key('home-before-start-star-cell-$index')
                    : null,
                missedKey: dayState == HomeGridStarDayState.missed
                    ? Key('home-missed-star-cell-$index')
                    : null,
                futureKey: dayState == HomeGridStarDayState.future
                    ? Key('home-future-star-cell-$index')
                    : null,
                todayKey: isToday ? Key('home-today-star-cell-$index') : null,
                completionSuccessAnimationToken:
                    completionSuccessAnimationToken,
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

  HomeGridStarDayState _resolveDayState({
    required DateTime date,
    required DateTime startDate,
    required DateTime todayDate,
    required bool isCompleted,
  }) {
    if (date.isBefore(startDate)) {
      return HomeGridStarDayState.beforeStart;
    }
    if (date.isAfter(todayDate)) {
      return HomeGridStarDayState.future;
    }
    if (isCompleted) {
      return HomeGridStarDayState.completed;
    }
    return HomeGridStarDayState.missed;
  }
}

class _GridStarCell extends StatefulWidget {
  const _GridStarCell({
    required this.size,
    required this.dayState,
    required this.isSelected,
    required this.isToday,
    required this.accentColor,
    required this.onTap,
    required this.completionSuccessAnimationToken,
    super.key,
    this.selectedKey,
    this.completedKey,
    this.beforeStartKey,
    this.missedKey,
    this.futureKey,
    this.todayKey,
  });

  final double size;
  final HomeGridStarDayState dayState;
  final bool isSelected;
  final bool isToday;
  final Color accentColor;
  final VoidCallback? onTap;
  final int? completionSuccessAnimationToken;
  final Key? selectedKey;
  final Key? completedKey;
  final Key? beforeStartKey;
  final Key? missedKey;
  final Key? futureKey;
  final Key? todayKey;

  @override
  State<_GridStarCell> createState() => _GridStarCellState();
}

class _GridStarCellState extends State<_GridStarCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 760),
  );
  late final Animation<double> _pulse =
      TweenSequence<double>(<TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(
            begin: 1,
            end: 1.62,
          ).chain(CurveTween(curve: Curves.easeOutCubic)),
          weight: 24,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(
            begin: 1.62,
            end: 0.92,
          ).chain(CurveTween(curve: Curves.easeInOutCubic)),
          weight: 20,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(
            begin: 0.92,
            end: 1,
          ).chain(CurveTween(curve: Curves.easeInOutCubic)),
          weight: 56,
        ),
      ]).animate(_controller);

  @override
  void didUpdateWidget(covariant _GridStarCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected &&
        widget.completionSuccessAnimationToken != null &&
        widget.completionSuccessAnimationToken !=
            oldWidget.completionSuccessAnimationToken) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double sizeMultiplier = widget.isToday
        ? 1.5
        : widget.dayState == HomeGridStarDayState.completed
        ? 1.2
        : 1.0;
    final double iconSize = (widget.size * 0.62 * sizeMultiplier).toDouble();

    return SizedBox(
      width: widget.size,
      height: widget.size,
      key: widget.selectedKey,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: widget.onTap,
          child: Container(
            key: _cellStateKey(),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? widget.accentColor.withValues(alpha: 0.14)
                  : null,
              borderRadius: BorderRadius.circular(4),
              border: widget.isSelected && !widget.isToday
                  ? Border.all(
                      color: widget.accentColor.withValues(alpha: 0.32),
                    )
                  : null,
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget? child) {
                  return Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      if (_controller.isAnimating &&
                          widget.dayState == HomeGridStarDayState.completed)
                        Opacity(
                          opacity: 1,
                          child: CustomPaint(
                            size: Size.square(widget.size * 3),
                            painter: _StarFireworkPainter(
                              color: widget.accentColor,
                              progress: _controller.value,
                            ),
                          ),
                        ),
                      Transform.scale(scale: _pulse.value, child: child),
                    ],
                  );
                },
                child: SizedBox(
                  key: widget.todayKey,
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
    switch (widget.dayState) {
      case HomeGridStarDayState.beforeStart:
      case HomeGridStarDayState.future:
        return 'assets/icons/ic_star.svg';
      case HomeGridStarDayState.completed:
      case HomeGridStarDayState.missed:
        return 'assets/icons/ic_star_active.svg';
    }
  }

  Color _starColor() {
    if (widget.isSelected) {
      return widget.accentColor.withValues(alpha: 0.98);
    }
    switch (widget.dayState) {
      case HomeGridStarDayState.beforeStart:
        return AppColors.white.withValues(alpha: 0.1);
      case HomeGridStarDayState.completed:
        return widget.accentColor.withValues(alpha: 0.88);
      case HomeGridStarDayState.missed:
        return widget.accentColor.withValues(alpha: 0.28);
      case HomeGridStarDayState.future:
        return AppColors.white.withValues(alpha: 0.2);
    }
  }

  Key? _cellStateKey() {
    if (widget.completedKey != null) {
      return widget.completedKey;
    }
    if (widget.beforeStartKey != null) {
      return widget.beforeStartKey;
    }
    if (widget.missedKey != null) {
      return widget.missedKey;
    }
    if (widget.futureKey != null) {
      return widget.futureKey;
    }
    return null;
  }
}

class _StarFireworkPainter extends CustomPainter {
  const _StarFireworkPainter({required this.color, required this.progress});

  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final eased = Curves.easeOutCubic.transform(progress.clamp(0, 1));
    final fade = (1 - Curves.easeIn.transform(progress.clamp(0, 1))).clamp(
      0.0,
      1.0,
    );
    final outerRadius = size.shortestSide * (0.08 + eased * 0.34);
    final innerRadius = size.shortestSide * (0.04 + eased * 0.16);
    final primaryPaint = Paint()
      ..color = color.withValues(alpha: fade * 0.78)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final secondaryPaint = Paint()
      ..color = AppColors.white.withValues(alpha: fade * 0.72)
      ..style = PaintingStyle.fill;

    for (int index = 0; index < 12; index += 1) {
      final angle = (math.pi * 2 / 12) * index;
      final start = Offset(
        center.dx + math.cos(angle) * innerRadius,
        center.dy + math.sin(angle) * innerRadius,
      );
      final end = Offset(
        center.dx + math.cos(angle) * outerRadius,
        center.dy + math.sin(angle) * outerRadius,
      );
      canvas.drawLine(start, end, primaryPaint);

      if (index.isEven) {
        final dotAngle = angle + math.pi / 12;
        final dotRadius = outerRadius * 0.82;
        final dotCenter = Offset(
          center.dx + math.cos(dotAngle) * dotRadius,
          center.dy + math.sin(dotAngle) * dotRadius,
        );
        canvas.drawCircle(dotCenter, size.shortestSide * 0.015, secondaryPaint);
      }
    }

    final ringPaint = Paint()
      ..color = color.withValues(alpha: fade * 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawCircle(center, outerRadius * 0.72, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _StarFireworkPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.progress != progress;
  }
}

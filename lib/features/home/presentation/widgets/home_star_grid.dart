import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:starnyx/core/constants/core_constants.dart';

import 'home_grid_utils.dart';

const double _kRingStrokeWidth = 1.6;

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
    required this.symbolKey,
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

  /// Stable habit symbol key (e.g. 'star', 'clover', 'flame') used to render
  /// each cell. Defaults to `HabitSymbols.defaultKey` ('star').
  final String symbolKey;

  static const double _gridSpacing = 3;

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
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
                symbolKey: symbolKey,
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
    required this.symbolKey,
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
  final String symbolKey;
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
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final currentlyLit = widget.dayState == HomeGridStarDayState.completed;
    final wasLit = oldWidget.dayState == HomeGridStarDayState.completed;

    // Lighting up: haptic feedback, no celebration on un-lighting.
    if (currentlyLit && !wasLit) {
      HapticFeedback.lightImpact();
    }

    if (!disableAnimations &&
        widget.isSelected &&
        currentlyLit &&
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
    final bool lit = widget.dayState == HomeGridStarDayState.completed;
    final bool todayNotLit = widget.isToday && !lit;
    final bool isDotState =
        widget.dayState == HomeGridStarDayState.beforeStart ||
        widget.dayState == HomeGridStarDayState.future;
    final List<List<dynamic>> iconData = HabitSymbols.iconFor(widget.symbolKey);

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
                      if (_controller.isAnimating && lit)
                        Opacity(
                          opacity: 1,
                          child: CustomPaint(
                            size: Size.square(widget.size * 3),
                            painter: _BloomPainter(
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
                  child: _DayCellContent(
                    dayState: widget.dayState,
                    lit: lit,
                    todayNotLit: todayNotLit,
                    isDotState: isDotState,
                    iconData: iconData,
                    color: widget.accentColor,
                    cellSize: widget.size,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
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

/// Renders a single grid day cell according to its state:
/// - future / before-start: small dot
/// - missed: symbol stroke at ~0.15 opacity, no glow
/// - lit: filled accent disc with soft glow, symbol drawn dark inside
/// - today (not lit): ring outline, keeps size emphasis
class _DayCellContent extends StatelessWidget {
  const _DayCellContent({
    required this.dayState,
    required this.lit,
    required this.todayNotLit,
    required this.isDotState,
    required this.iconData,
    required this.color,
    required this.cellSize,
  });

  final HomeGridStarDayState dayState;
  final bool lit;
  final bool todayNotLit;
  final bool isDotState;
  final List<List<dynamic>> iconData;
  final Color color;
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    if (lit) {
      return _LitCell(iconData: iconData, color: color, cellSize: cellSize);
    }
    if (todayNotLit) {
      return _TodayRingCell(
        iconData: iconData,
        color: color,
        cellSize: cellSize,
      );
    }
    if (isDotState) {
      return _DotCell(
        cellSize: cellSize,
        color: AppColors.white.withValues(alpha: 0.05),
      );
    }
    if (dayState == HomeGridStarDayState.missed) {
      return _DotCell(cellSize: cellSize, color: AppColors.surfaceLevel3);
    }
    return const SizedBox.shrink();
  }
}

/// Lit day: filled accent-colored disc with soft glow, symbol drawn dark inside.
class _LitCell extends StatelessWidget {
  const _LitCell({
    required this.iconData,
    required this.color,
    required this.cellSize,
  });

  final List<List<dynamic>> iconData;
  final Color color;
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    final double discSize = cellSize * 0.86;
    return Container(
      width: discSize,
      height: discSize,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withValues(alpha: 0.55),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: AppIcon(
          icon: iconData,
          color: AppColors.black,
          size: discSize * 0.56,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

/// Today (not lit): ring outline, keeps size emphasis.
class _TodayRingCell extends StatelessWidget {
  const _TodayRingCell({
    required this.iconData,
    required this.color,
    required this.cellSize,
  });

  final List<List<dynamic>> iconData;
  final Color color;
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    final double ringSize = cellSize * 0.74;
    return Container(
      width: ringSize,
      height: ringSize,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: _kRingStrokeWidth),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: AppIcon(
        icon: iconData,
        color: color,
        size: ringSize * 0.54,
        strokeWidth: 2,
      ),
    );
  }
}

/// Unlit day: a quiet disc. Missed days use a slightly stronger tone than
/// future / before-start days so the year still reads as a matrix.
class _DotCell extends StatelessWidget {
  const _DotCell({required this.cellSize, required this.color});

  final double cellSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final double dotSize = cellSize * 0.54;
    return Container(
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// Bloom painter: symbol-agnostic light-up effect with a radial bloom plus
/// 7 soft particles in the accent color. Used when a day lights up.
class _BloomPainter extends CustomPainter {
  const _BloomPainter({required this.color, required this.progress});

  final Color color;
  final double progress;

  static const int _particleCount = 7;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final eased = Curves.easeOutCubic.transform(progress.clamp(0, 1));
    final fade = (1 - Curves.easeIn.transform(progress.clamp(0, 1))).clamp(
      0.0,
      1.0,
    );

    // Radial bloom: expanding soft circle that fades out.
    final bloomRadius = size.shortestSide * (0.12 + eased * 0.5);
    final bloomPaint = Paint()
      ..color = color.withValues(alpha: fade * 0.45)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, bloomRadius, bloomPaint);

    // 7 soft particles scattered radially, pulsing in and out.
    for (int i = 0; i < _particleCount; i += 1) {
      final angle = (math.pi * 2 / _particleCount) * i;
      final particleRadius = size.shortestSide * (0.18 + eased * 0.42);
      final particleCenter = Offset(
        center.dx + math.cos(angle) * particleRadius,
        center.dy + math.sin(angle) * particleRadius,
      );
      final particleAlpha = fade * 0.85 * (0.5 + 0.5 * math.sin(i + progress));
      final particleSize = size.shortestSide * (0.03 + (1 - progress) * 0.02);
      final particlePaint = Paint()
        ..color = color.withValues(alpha: particleAlpha.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(particleCenter, particleSize, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BloomPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.progress != progress;
  }
}

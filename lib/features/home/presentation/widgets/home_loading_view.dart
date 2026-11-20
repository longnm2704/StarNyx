import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/features/home/presentation/widgets/home_grid_utils.dart';

class HomeLoadingView extends StatefulWidget {
  const HomeLoadingView({required this.accentColor, super.key});

  final Color accentColor;

  @override
  State<HomeLoadingView> createState() => _HomeLoadingViewState();
}

class _HomeLoadingViewState extends State<HomeLoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void initState() {
    super.initState();
    _controller.repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant HomeLoadingView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncAnimation() {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableAnimations) {
      _controller
        ..stop()
        ..value = 0.42;
      return;
    }
    if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                _LoadingAppBar(
                  animation: _controller,
                  accentColor: widget.accentColor,
                ),
                const SizedBox(height: AppSpacing.md),
                _LoadingHeader(
                  animation: _controller,
                  accentColor: widget.accentColor,
                ),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLevel1,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: _LoadingStarGrid(
                      animation: _controller,
                      accentColor: widget.accentColor,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _LoadingYearRow(
                  animation: _controller,
                  color: widget.accentColor,
                ),
                const SizedBox(height: AppSpacing.md),
                _LoadingDateBar(
                  animation: _controller,
                  color: widget.accentColor,
                ),
                const SizedBox(height: AppSpacing.sm),
                _LoadingPill(
                  animation: _controller,
                  width: 152,
                  height: 14,
                  color: widget.accentColor,
                  opacity: 0.16,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingAppBar extends StatelessWidget {
  const _LoadingAppBar({required this.animation, required this.accentColor});

  final Animation<double> animation;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accentColor.withValues(alpha: 0.72),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _LoadingPill(
          animation: animation,
          width: 96,
          height: 20,
          color: accentColor,
          opacity: 0.14,
        ),
        const Spacer(),
        _LoadingCircle(animation: animation, color: accentColor, size: 36),
      ],
    );
  }
}

class _LoadingHeader extends StatelessWidget {
  const _LoadingHeader({required this.animation, required this.accentColor});

  final Animation<double> animation;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceLevel1,
            border: Border.all(color: accentColor.withValues(alpha: 0.16)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: accentColor.withValues(alpha: 0.2),
                blurRadius: 26,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _LoadingPill(
          animation: animation,
          width: 168,
          height: 28,
          color: accentColor,
        ),
        const SizedBox(height: AppSpacing.xs),
        _LoadingPill(
          animation: animation,
          width: 118,
          height: 14,
          color: accentColor,
          opacity: 0.18,
        ),
      ],
    );
  }
}

class _LoadingStarGrid extends StatelessWidget {
  const _LoadingStarGrid({required this.animation, required this.accentColor});

  final Animation<double> animation;
  final Color accentColor;

  static const double _gridSpacing = 3;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final horizontalSpacing = (homeGridColumnCount - 1) * _gridSpacing;
        final cellExtent =
            (constraints.maxWidth - horizontalSpacing) / homeGridColumnCount;
        final effectiveCellExtent = math.max(8.0, cellExtent).toDouble();
        final rowCount = math.max(
          1,
          (constraints.maxHeight / (effectiveCellExtent + _gridSpacing))
              .floor(),
        );
        final itemCount = math.min(216, rowCount * homeGridColumnCount);

        return AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget? child) {
            return GridView.builder(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: homeGridColumnCount,
                crossAxisSpacing: _gridSpacing,
                mainAxisSpacing: _gridSpacing,
                mainAxisExtent: effectiveCellExtent,
              ),
              itemCount: itemCount,
              itemBuilder: (BuildContext context, int index) {
                final wave =
                    0.5 +
                    (0.5 *
                        math.sin(
                          (animation.value * math.pi * 2) + (index * 0.31),
                        ));
                final isHighlight = index % 17 == 0 || index % 29 == 0;
                final opacity = isHighlight
                    ? 0.18 + (wave * 0.24)
                    : 0.08 + (wave * 0.1);
                final size = effectiveCellExtent * (isHighlight ? 0.5 : 0.34);

                return Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.lerp(
                        accentColor,
                        AppColors.white,
                        isHighlight ? 0.22 : 0.04,
                      )!.withValues(alpha: opacity),
                      boxShadow: isHighlight
                          ? <BoxShadow>[
                              BoxShadow(
                                color: accentColor.withValues(
                                  alpha: opacity * 0.32,
                                ),
                                blurRadius: 10,
                              ),
                            ]
                          : null,
                    ),
                    child: SizedBox.square(dimension: size),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _LoadingYearRow extends StatelessWidget {
  const _LoadingYearRow({required this.animation, required this.color});

  final Animation<double> animation;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _LoadingCircle(animation: animation, color: color),
        const Spacer(),
        _LoadingPill(animation: animation, width: 88, height: 18, color: color),
        const Spacer(),
        _LoadingCircle(animation: animation, color: color),
      ],
    );
  }
}

class _LoadingDateBar extends StatelessWidget {
  const _LoadingDateBar({required this.animation, required this.color});

  final Animation<double> animation;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _LoadingCircle(animation: animation, color: color, size: 44),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _LoadingPill(
            animation: animation,
            width: double.infinity,
            height: 52,
            color: color,
            opacity: 0.18,
            radius: AppRadius.pill,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _LoadingCircle(animation: animation, color: color, size: 44),
      ],
    );
  }
}

class _LoadingCircle extends StatelessWidget {
  const _LoadingCircle({
    required this.animation,
    required this.color,
    this.size = 36,
  });

  final Animation<double> animation;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _LoadingPill(
      animation: animation,
      width: size,
      height: size,
      color: color,
      opacity: 0.14,
      radius: size / 2,
    );
  }
}

class _LoadingPill extends StatelessWidget {
  const _LoadingPill({
    required this.animation,
    required this.width,
    required this.height,
    required this.color,
    this.opacity = 0.22,
    this.radius,
  });

  final Animation<double> animation;
  final double width;
  final double height;
  final Color color;
  final double opacity;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final shimmer = 0.72 + (0.28 * math.sin(animation.value * math.pi * 2));
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius ?? height / 2),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[
                color.withValues(alpha: opacity * 0.7),
                Color.lerp(
                  color,
                  AppColors.white,
                  0.24,
                )!.withValues(alpha: opacity * shimmer),
                color.withValues(alpha: opacity * 0.62),
              ],
            ),
            border: Border.all(color: AppColors.borderSubtle),
          ),
        );
      },
    );
  }
}

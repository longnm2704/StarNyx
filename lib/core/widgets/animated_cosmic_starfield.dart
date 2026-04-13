import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';

// Animated PNG starfield used behind StarNyx screens.
class AnimatedCosmicStarfield extends StatefulWidget {
  const AnimatedCosmicStarfield({required this.enabled, super.key});

  final bool enabled;

  @override
  State<AnimatedCosmicStarfield> createState() =>
      _AnimatedCosmicStarfieldState();
}

class _AnimatedCosmicStarfieldState extends State<AnimatedCosmicStarfield>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_CosmicStarSpec> _stars = _createStars();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    );

    if (widget.enabled) {
      _controller.repeat();
    } else {
      _controller.value = 0.32;
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedCosmicStarfield oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.enabled == widget.enabled) {
      return;
    }

    if (widget.enabled) {
      _controller.repeat();
      return;
    }

    _controller
      ..stop()
      ..value = 0.32;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            final progress = _controller.value * math.pi * 2;

            return Stack(
              fit: StackFit.expand,
              children: _stars
                  .map((_CosmicStarSpec star) {
                    final baseX = star.normalizedX * width;
                    final baseY = star.normalizedY * height * 0.74;
                    final driftX =
                        math.sin(progress * star.driftSpeed + star.phase) *
                        star.driftRadius;
                    final driftY =
                        math.cos(
                          progress * (star.driftSpeed * 0.92) + star.phase,
                        ) *
                        (star.driftRadius * 0.72);
                    final flicker =
                        0.42 +
                        (0.58 *
                            (0.5 +
                                (0.5 *
                                    math.sin(
                                      progress * star.twinkleSpeed + star.phase,
                                    ))));
                    final opacity = (star.baseOpacity * flicker).clamp(
                      0.08,
                      0.72,
                    );
                    final starColor = star.color.withValues(alpha: opacity);

                    return Positioned(
                      left: baseX + driftX,
                      top: baseY + driftY,
                      child: Transform.rotate(
                        angle: star.rotation + (progress * star.rotationSpeed),
                        child: Transform.scale(
                          scale: 0.94 + (flicker * 0.18),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: starColor.withValues(
                                    alpha: opacity * 0.16,
                                  ),
                                  blurRadius: star.size * 0.55,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/icons/ic_star.png',
                              width: star.size,
                              height: star.size,
                              color: starColor,
                              colorBlendMode: BlendMode.srcIn,
                              filterQuality: FilterQuality.medium,
                            ),
                          ),
                        ),
                      ),
                    );
                  })
                  .toList(growable: false),
            );
          },
        );
      },
    );
  }
}

List<_CosmicStarSpec> _createStars() {
  final random = math.Random(87123);
  final stars = <_CosmicStarSpec>[];

  for (var index = 0; index < 30; index++) {
    final nearTop = index < 22;
    final normalizedY = nearTop
        ? random.nextDouble() * 0.48
        : 0.08 + (random.nextDouble() * 0.54);
    final isAccent = random.nextDouble() > 0.88;

    stars.add(
      _CosmicStarSpec(
        normalizedX: random.nextDouble(),
        normalizedY: normalizedY,
        size: 8 + (random.nextDouble() * 10),
        baseOpacity: 0.14 + (random.nextDouble() * 0.26),
        phase: random.nextDouble() * math.pi * 2,
        twinkleSpeed: 0.9 + (random.nextDouble() * 1.8),
        driftSpeed: 0.65 + (random.nextDouble() * 1.6),
        driftRadius: 1.2 + (random.nextDouble() * 4.8),
        rotation: random.nextDouble() * math.pi * 2,
        rotationSpeed: (random.nextDouble() - 0.5) * 0.05,
        color: isAccent ? AppColors.accentLavender : AppColors.star,
      ),
    );
  }

  return stars;
}

class _CosmicStarSpec {
  const _CosmicStarSpec({
    required this.normalizedX,
    required this.normalizedY,
    required this.size,
    required this.baseOpacity,
    required this.phase,
    required this.twinkleSpeed,
    required this.driftSpeed,
    required this.driftRadius,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
  });

  final double normalizedX;
  final double normalizedY;
  final double size;
  final double baseOpacity;
  final double phase;
  final double twinkleSpeed;
  final double driftSpeed;
  final double driftRadius;
  final double rotation;
  final double rotationSpeed;
  final Color color;
}

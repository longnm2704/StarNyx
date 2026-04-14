import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';

class HomeLoadingView extends StatelessWidget {
  const HomeLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const CosmicBackground(child: Center(child: _HomeLoadingStars()));
  }
}

class _HomeLoadingStars extends StatefulWidget {
  const _HomeLoadingStars();

  @override
  State<_HomeLoadingStars> createState() => _HomeLoadingStarsState();
}

class _HomeLoadingStarsState extends State<_HomeLoadingStars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const List<_StarSpec> _stars = <_StarSpec>[
    _StarSpec(
      alignment: Alignment(-0.34, -0.48),
      size: 24,
      phase: 0.9,
      tint: Color(0xFFF3ECFF),
      baseOpacity: 0.56,
      glowOpacity: 0.2,
      scaleRange: 0.12,
      driftX: 6.8,
      driftY: 4.6,
    ),
    _StarSpec(
      alignment: Alignment(0.04, -0.02),
      size: 48,
      phase: 0,
      tint: Color(0xFFF9F5FF),
      baseOpacity: 0.74,
      glowOpacity: 0.34,
      scaleRange: 0.14,
      driftX: 4.8,
      driftY: 7.8,
    ),
    _StarSpec(
      alignment: Alignment(0.32, 0.54),
      size: 30,
      phase: 2.5,
      tint: Color(0xFFEDE3FF),
      baseOpacity: 0.52,
      glowOpacity: 0.18,
      scaleRange: 0.1,
      driftX: 7.6,
      driftY: 4.2,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 138,
              height: 146,
              child: Stack(
                clipBehavior: Clip.none,
                children: _stars.map(_buildStar).toList(growable: false),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStar(_StarSpec spec) {
    final progress = (_controller.value * 2 * math.pi) + spec.phase;
    final pulse = (math.sin(progress) + 1) / 2;
    final shimmer = math.pow(pulse, 1.8).toDouble();
    final opacity = spec.baseOpacity + (shimmer * (1 - spec.baseOpacity));
    final scale = 0.94 + (shimmer * spec.scaleRange);
    final glowSize = spec.size * (1.45 + (shimmer * 0.16));
    final drift = Offset(
      math.sin(progress * 0.9) * spec.driftX,
      math.cos((progress * 0.78) + spec.phase) * spec.driftY,
    );

    return Align(
      alignment: spec.alignment,
      child: Transform.translate(
        offset: drift,
        child: Transform.scale(
          scale: scale,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: <Widget>[
              IgnorePointer(
                child: Opacity(
                  opacity: spec.glowOpacity + (shimmer * 0.18),
                  child: Container(
                    width: glowSize,
                    height: glowSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: <Color>[
                          spec.tint.withValues(alpha: 0.82),
                          spec.tint.withValues(alpha: 0.24),
                          spec.tint.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Opacity(
                opacity: opacity,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(spec.tint, BlendMode.modulate),
                  child: Image.asset(
                    'assets/icons/ic_star.png',
                    width: spec.size,
                    height: spec.size,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StarSpec {
  const _StarSpec({
    required this.alignment,
    required this.size,
    required this.phase,
    required this.tint,
    required this.baseOpacity,
    required this.glowOpacity,
    required this.scaleRange,
    required this.driftX,
    required this.driftY,
  });

  final Alignment alignment;
  final double size;
  final double phase;
  final Color tint;
  final double baseOpacity;
  final double glowOpacity;
  final double scaleRange;
  final double driftX;
  final double driftY;
}

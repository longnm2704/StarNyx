import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/app_colors.dart';
import 'package:starnyx/core/widgets/animated_cosmic_starfield.dart';

// Shared background used by StarNyx screens to keep the cosmic feel consistent.
class CosmicBackground extends StatelessWidget {
  const CosmicBackground({
    required this.child,
    super.key,
    this.bottomGlowColor = AppColors.backgroundBottom,
    this.showStars = true,
  });

  final Widget child;
  final Color bottomGlowColor;
  final bool showStars;

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.screenGradient),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, 0.92),
                  radius: 1.05,
                  colors: <Color>[
                    bottomGlowColor.withValues(alpha: 0.58),
                    Colors.transparent,
                  ],
                  stops: const <double>[0, 1],
                ),
              ),
            ),
          ),
          if (showStars)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedCosmicStarfield(enabled: !disableAnimations),
              ),
            ),
          child,
        ],
      ),
    );
  }
}

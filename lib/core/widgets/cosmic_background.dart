import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/app_colors.dart';
import 'package:starnyx/core/widgets/animated_cosmic_starfield.dart';

// Shared background used by StarNyx screens to keep the cosmic feel consistent.
class CosmicBackground extends StatelessWidget {
  const CosmicBackground({
    required this.child,
    super.key,
    this.bottomGlowColor,
    this.accentColor,
    this.showStars = true,
  });

  final Widget child;
  final Color? bottomGlowColor;
  final Color? accentColor;
  final bool showStars;

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final Color effectiveBottomGlow = accentColor ?? bottomGlowColor ?? AppColors.backgroundBottom;

    final Gradient backgroundGradient = accentColor != null
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              AppColors.background,
              AppColors.background,
              Color.lerp(accentColor, AppColors.background, 0.64)!,
              Color.lerp(accentColor, AppColors.background, 0.32)!,
            ],
            stops: const <double>[0.0, 0.34, 0.74, 1.0],
          )
        : AppColors.screenGradient;

    return DecoratedBox(
      decoration: BoxDecoration(gradient: backgroundGradient),
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
                    effectiveBottomGlow.withValues(alpha: 0.58),
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

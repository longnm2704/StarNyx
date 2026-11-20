import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';

/// `#0A0A0C` surface with a hairline border: the standard content card.
///
/// Clips its child, so InkWell rows inside get rounded ripples. Pass
/// `padding: null` when the children bring their own insets.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.padding = AppSpacing.cardPadding,
    this.radius = AppRadius.card,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceLevel1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );
  }
}

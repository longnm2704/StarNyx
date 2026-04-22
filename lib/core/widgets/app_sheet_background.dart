import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/cosmic_background.dart';

class AppSheetBackground extends StatelessWidget {
  const AppSheetBackground({
    required this.child,
    this.accentColor,
    this.borderRadius,
    super.key,
  });

  final Widget child;
  final Color? accentColor;
  final BorderRadius? borderRadius;

  static LinearGradient buildGradient(Color? accentColor) {
    final Color top = accentColor != null
        ? Color.lerp(accentColor, AppColors.black, 0.42)!
        : AppColors.sheetTop;
    final Color mid = accentColor != null
        ? Color.lerp(accentColor, AppColors.black, 0.72)!
        : AppColors.sheetMid;

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[top, mid, AppColors.background],
      stops: const <double>[0.0, 0.48, 1.0],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: buildGradient(accentColor),
        borderRadius: borderRadius ??
            const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl * 1.5),
            ),
      ),
      child: CosmicBackground(
        accentColor: accentColor,
        child: child,
      ),
    );
  }
}

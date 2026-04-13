import 'package:flutter/material.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:starnyx/core/constants/core_constants.dart';

class TopCircleAssetIconButton extends StatelessWidget {
  const TopCircleAssetIconButton({
    required this.assetPath,
    required this.onPressed,
    required this.tooltip,
    super.key,
  });

  final String assetPath;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSize.iconButton,
      height: AppSize.iconButton,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.78),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.52)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: AppSvgIcon(
          assetPath: assetPath,
          size: 22,
          color: AppColors.textPrimary.withValues(alpha: 0.88),
          semanticsLabel: tooltip,
        ),
      ),
    );
  }
}

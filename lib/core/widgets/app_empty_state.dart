import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';

import 'gradient_outline_button.dart';
import 'app_svg_icon.dart';

// Shared empty-state card for screens that have no content yet.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.title,
    required this.message,
    super.key,
    this.iconAssetPath = 'assets/icons/ic_sparkles.svg',
    this.actionLabel,
    this.onActionPressed,
  });

  final String iconAssetPath;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.surfaceGlass.withValues(alpha: 0.94),
            AppColors.surface.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.outlineSoft.withValues(alpha: 0.24),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.accentFillGradient,
                border: Border.all(
                  color: AppColors.accentLavender.withValues(alpha: 0.18),
                ),
              ),
              child: Center(
                child: AppSvgIcon(
                  assetPath: iconAssetPath,
                  size: 28,
                  color: AppColors.accentLavender,
                  semanticsLabel: title,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.35,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onActionPressed != null) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              GradientOutlineButton(
                label: actionLabel!,
                onPressed: onActionPressed!,
                height: 50,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

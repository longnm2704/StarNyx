import 'package:flutter/material.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_color_utils.dart';

class ActiveStarnyxSpotlight extends StatelessWidget {
  const ActiveStarnyxSpotlight({required this.activeStarnyx, super.key});

  final StarNyx activeStarnyx;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceTop = Color.lerp(
      AppColors.surfaceElevated,
      AppColors.backgroundMid,
      0.32,
    )!;
    final surfaceBottom = Color.lerp(
      AppColors.surface,
      AppColors.background,
      0.18,
    )!;

    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[surfaceTop, surfaceBottom],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.46)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'home.active_constellation_title'.tr(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.3,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: starnyxColorFromHex(activeStarnyx.color),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  activeStarnyx.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'home.active_constellation_hint'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:starnyx/core/constants/core_constants.dart';

class HomeSwipeUpHint extends StatelessWidget {
  const HomeSwipeUpHint({required this.onTap, required this.isBusy, super.key});

  final VoidCallback onTap;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      onTap: isBusy ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Transform.translate(
              offset: const Offset(0, -4),
              child: AppSvgIcon(
                assetPath: 'assets/icons/ic_chevron_up.svg',
                color: AppColors.textMuted.withValues(alpha: 0.48),
                size: 20,
                semanticsLabel: 'home.swipe_hint'.tr(),
              ),
            ),
            Text(
              'home.swipe_hint'.tr(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

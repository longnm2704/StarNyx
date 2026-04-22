import 'package:flutter/material.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:starnyx/core/constants/core_constants.dart';

class HomeErrorView extends StatelessWidget {
  const HomeErrorView({required this.onRetry, this.accentColor, super.key});

  final VoidCallback onRetry;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return CosmicBackground(
      accentColor: accentColor,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.contentMaxWidth,
            ),
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: AppEmptyState(
                iconAssetPath: 'assets/icons/ic_error.svg',
                title: 'home.load_error_title'.tr(),
                message: 'home.load_error_message'.tr(),
                actionLabel: 'home.retry'.tr(),
                onActionPressed: onRetry,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

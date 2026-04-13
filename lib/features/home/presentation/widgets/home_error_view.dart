import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';

class HomeErrorView extends StatelessWidget {
  const HomeErrorView({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return CosmicBackground(
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.contentMaxWidth,
            ),
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: AppEmptyState(
                icon: Icons.sync_problem_outlined,
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

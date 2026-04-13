import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';

class HomeLoadingView extends StatelessWidget {
  const HomeLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const CosmicBackground(
      child: Center(
        child: CircularProgressIndicator(color: AppColors.accentPink),
      ),
    );
  }
}

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

class ReturningPlaceholderView extends StatelessWidget {
  const ReturningPlaceholderView({required this.starnyxCount, super.key});

  final int starnyxCount;

  @override
  Widget build(BuildContext context) {
    return CosmicBackground(
      bottomGlowColor: AppColors.accentOrange,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.contentMaxWidth,
            ),
            child: Padding(
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AppSectionTitle(
                    title: 'home.returning_title'.tr(),
                    subtitle: 'home.returning_subtitle'.tr(
                      args: <String>[starnyxCount.toString()],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.section),
                  AppEmptyState(
                    title: 'home.returning_empty_title'.tr(),
                    message: 'home.returning_empty_message'.tr(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

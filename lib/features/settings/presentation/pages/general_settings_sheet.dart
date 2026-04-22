import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_header.dart';

class GeneralSettingsSheet extends StatelessWidget {
  const GeneralSettingsSheet({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topInset = mediaQuery.viewPadding.top > 0
        ? mediaQuery.viewPadding.top
        : mediaQuery.padding.top;
    final headerTopPadding = (topInset < 24 ? 24.0 : topInset) + AppSpacing.lg;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            headerTopPadding,
            AppSpacing.pageHorizontal,
            AppSpacing.md,
          ),
          child: StarnyxFormHeader(
            title: 'settings.general_title'.tr(),
            onClosePressed: onBack,
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageHorizontal,
              AppSpacing.md,
              AppSpacing.pageHorizontal,
              AppSpacing.xl,
            ),
            children: [
              _GeneralSettingTile(
                title: 'settings.language_label'.tr(),
                value: 'settings.language_value'.tr(),
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.md),
              _GeneralSettingTile(
                title: 'settings.time_format_label'.tr(),
                value: 'settings.time_format_24h'.tr(),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GeneralSettingTile extends StatelessWidget {
  const _GeneralSettingTile({
    required this.title,
    required this.value,
    required this.onTap,
  });

  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.accentLavender,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

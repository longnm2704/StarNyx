import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_header.dart';

const LinearGradient _sheetTopDownGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: <Color>[AppColors.sheetTop, AppColors.sheetMid, AppColors.background],
  stops: <double>[0.0, 0.48, 1.0],
);

Future<void> showGeneralSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.black.withValues(alpha: 0.72),
    builder: (BuildContext context) {
      return const GeneralSettingsSheet();
    },
  );
}

class GeneralSettingsSheet extends StatelessWidget {
  const GeneralSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topInset = mediaQuery.viewPadding.top > 0 ? mediaQuery.viewPadding.top : mediaQuery.padding.top;
    final headerTopPadding = (topInset < 24 ? 24.0 : topInset) + AppSpacing.lg;

    return FractionallySizedBox(
      heightFactor: 1.0,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: _sheetTopDownGradient,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl * 1.5)),
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Stack(
            children: [
              const Positioned.fill(child: CosmicBackground(child: SizedBox.expand())),
              Column(
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
                      onClosePressed: () => Navigator.of(context).pop(),
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
                          value: 'English', // Current language display
                          onTap: () {
                            // Logic to change language
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _GeneralSettingTile(
                          title: 'settings.appearance_label'.tr(),
                          value: 'settings.theme_dark'.tr(),
                          onTap: () {
                            // Logic to change theme
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _GeneralSettingTile(
                          title: 'settings.time_format_label'.tr(),
                          value: 'settings.time_format_24h'.tr(),
                          onTap: () {
                            // Logic to change time format
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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

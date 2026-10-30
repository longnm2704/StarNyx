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
    final bottomSafeInset = mediaQuery.viewPadding.bottom > 0
        ? mediaQuery.viewPadding.bottom
        : mediaQuery.padding.bottom;
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
            padding: EdgeInsets.fromLTRB(
              AppSpacing.pageHorizontal,
              AppSpacing.md,
              AppSpacing.pageHorizontal,
              AppSpacing.xl + bottomSafeInset,
            ),
            children: [
              _GeneralSettingTile(
                title: 'settings.language_label'.tr(),
                value: 'settings.language_value'.tr(),
                onTap: () => _showLanguagePicker(context),
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

  // Language names stay in their own language so users can always find theirs.
  static const _languageNames = <String, String>{
    'en': 'English',
    'vi': 'Tiếng Việt',
  };

  Future<void> _showLanguagePicker(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      // Root navigator so the picker covers the whole screen, not just the settings sheet.
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.black.withValues(alpha: 0.6),
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: BoxDecoration(
          color: AppColors.sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.62)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineSoft.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'settings.language_label'.tr(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final locale in context.supportedLocales) ...[
                _LanguageOption(
                  label:
                      _languageNames[locale.languageCode] ??
                      locale.languageCode,
                  code: locale.languageCode.toUpperCase(),
                  selected: locale == context.locale,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.setLocale(locale);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.code,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String code;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.lg);

    // Selected option gets the accent gradient as a 1.5px border.
    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        gradient: selected ? AppColors.accentGradient : null,
        color: selected ? null : AppColors.outlineSoft.withValues(alpha: 0.16),
        borderRadius: radius,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  AppColors.surfaceGlass,
                  selected ? AppColors.starMuted : AppColors.surface,
                ],
              ),
              borderRadius: radius,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? AppColors.accentViolet.withValues(alpha: 0.28)
                        : AppColors.surfaceElevated,
                  ),
                  child: Text(
                    code,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: selected
                          ? AppColors.accentLavender
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: AppDurations.fast,
                  child: selected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          key: ValueKey('selected'),
                          color: AppColors.accentLavender,
                          size: 24,
                        )
                      : Icon(
                          Icons.circle_outlined,
                          key: const ValueKey('unselected'),
                          color: AppColors.textMuted.withValues(alpha: 0.6),
                          size: 24,
                        ),
                ),
              ],
            ),
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                AppColors.surfaceGlass.withValues(alpha: 0.82),
                AppColors.surface.withValues(alpha: 0.72),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.outlineSoft.withValues(alpha: 0.16),
            ),
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
                        color: AppColors.accentLavender.withValues(alpha: 0.92),
                        fontWeight: FontWeight.w600,
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

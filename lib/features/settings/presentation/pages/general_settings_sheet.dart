import 'package:flutter/material.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/services/notification_service.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:starnyx/domain/usecases/sync_notifications_use_case.dart';
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
            ],
          ),
        ),
      ],
    );
  }

  // Language names stay in their own language so users can always find theirs.
  static const _languages = <String, ({String name, String flag})>{
    'en': (name: 'English', flag: 'assets/icons/us.png'),
    'vi': (name: 'Tiếng Việt', flag: 'assets/icons/vn.png'),
    'ja': (name: '日本語', flag: 'assets/icons/jp.png'),
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
          color: AppColors.sheet,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
          border: Border.all(color: AppColors.borderSubtle),
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
                    color: AppColors.borderFocus,
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
                      _languages[locale.languageCode]?.name ??
                      locale.languageCode,
                  flagAsset: _languages[locale.languageCode]?.flag,
                  selected: locale == context.locale,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.setLocale(locale);
                    final notificationService =
                        serviceLocator<NotificationService>();
                    notificationService.setTranslator(
                      (key, {namedArgs}) => context.tr(
                        key,
                        namedArgs: namedArgs?.cast<String, String>(),
                      ),
                    );
                    serviceLocator<SyncNotificationsUseCase>()
                        .rebuildAllFromLocalData();
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
    required this.flagAsset,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String? flagAsset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.card);

    // Selected option gets an emerald hairline border.
    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.borderSubtle,
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
              color: selected ? AppColors.surfaceLevel2 : AppColors.surfaceLevel1,
              borderRadius: radius,
            ),
            child: Row(
              children: [
                // Flag assets are already circular; the ring just lifts them off the card.
                Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.7)
                        : AppColors.borderSubtle,
                  ),
                  child: flagAsset == null
                      ? const AppIcon(
                          icon: HugeIconsStrokeRounded.strokeRoundedLanguages,
                          color: AppColors.textSecondary,
                        )
                      : Image.asset(flagAsset!, fit: BoxFit.cover),
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
                      ? const AppIcon(
                          icon: HugeIconsStrokeRounded.strokeRoundedCircleCheck,
                          key: ValueKey('selected'),
                          color: AppColors.primary,
                          size: 24,
                        )
                      : AppIcon(
                          icon: HugeIconsStrokeRounded.strokeRoundedCircle,
                          key: const ValueKey('unselected'),
                          color: AppColors.textTertiary.withValues(alpha: 0.6),
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
            color: AppColors.surfaceLevel1,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.borderSubtle),
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
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const AppIcon(
                icon: HugeIconsStrokeRounded.strokeRoundedChevronRight,
                color: AppColors.textTertiary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

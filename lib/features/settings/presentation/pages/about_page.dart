import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:starnyx/features/settings/presentation/widgets/settings_page_widgets.dart';

/// Full-screen "About StarNyx" page pushed from Settings; same header,
/// overlines and hairline cards as the backup screen.
class AboutPage extends StatelessWidget {
  const AboutPage({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal,
          AppSpacing.md,
          AppSpacing.pageHorizontal,
          AppSpacing.xxl + MediaQuery.paddingOf(context).bottom,
        ),
        children: <Widget>[
          SettingsBackHeader(
            title: 'settings.about_title'.tr(),
            backKey: const Key('about-back-button'),
            onBack: onBack,
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: const Center(
                child: AppIcon(
                  icon: HugeIconsStrokeRounded.strokeRoundedSparkles,
                  size: 34,
                  color: AppColors.onPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'app.title'.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'settings.about_made_with'.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          for (final (title, content) in <(String, String)>[
            ('settings.about_mission_title', 'settings.about_mission_content'),
            ('settings.about_privacy_title', 'settings.about_privacy_content'),
            (
              'settings.about_experience_title',
              'settings.about_experience_content',
            ),
          ]) ...<Widget>[
            SettingsSectionLabel(title.tr()),
            SettingsCard(
              child: Text(
                content.tr(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}

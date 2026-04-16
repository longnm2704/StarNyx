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

Future<void> showAboutStarnyxSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.black.withValues(alpha: 0.72),
    builder: (BuildContext context) {
      return const AboutStarnyxSheet();
    },
  );
}

class AboutStarnyxSheet extends StatelessWidget {
  const AboutStarnyxSheet({super.key});

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
                      title: 'settings.about_title'.tr(),
                      onClosePressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
                      children: [
                        const SizedBox(height: AppSpacing.xl),
                        Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.accentGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentViolet.withValues(alpha: 0.3),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: AppSvgIcon(
                                assetPath: 'assets/icons/ic_star_active.svg',
                                size: 50,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl * 2),
                        _AboutSection(
                          title: 'settings.about_mission_title'.tr(),
                          content: 'settings.about_mission_content'.tr(),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _AboutSection(
                          title: 'settings.about_privacy_title'.tr(),
                          content: 'settings.about_privacy_content'.tr(),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _AboutSection(
                          title: 'settings.about_experience_title'.tr(),
                          content: 'settings.about_experience_content'.tr(),
                        ),
                        const SizedBox(height: AppSpacing.xl * 2),
                        Center(
                          child: Text(
                            'settings.about_made_with'.tr(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textMuted,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
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

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.accentLavender,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
        ),
      ],
    );
  }
}

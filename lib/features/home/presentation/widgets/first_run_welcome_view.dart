import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:starnyx/features/home/presentation/widgets/top_circle_asset_icon_button.dart';
import 'package:starnyx/features/home/presentation/widgets/welcome_hero_icon.dart';

class FirstRunWelcomeView extends StatelessWidget {
  const FirstRunWelcomeView({super.key, this.onCreatePressed});

  final VoidCallback? onCreatePressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CosmicBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.pageVertical,
            AppSpacing.pageHorizontal,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: TopCircleAssetIconButton(
                  assetPath: 'assets/icons/ic_settings.svg',
                  tooltip: 'welcome.settings'.tr(),
                  onPressed: () {},
                ),
              ),
              const Spacer(),
              const WelcomeHeroIcon(),
              const SizedBox(height: AppSpacing.lg),
              RichText(
                text: TextSpan(
                  style: textTheme.headlineLarge,
                  children: <InlineSpan>[
                    TextSpan(text: 'welcome.title_lead'.tr()),
                    TextSpan(
                      text: 'welcome.title_emphasis'.tr(),
                      style: textTheme.headlineLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Text(
                  'welcome.subtitle'.tr(),
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              GradientOutlineButton(
                label: 'welcome.primary_action'.tr(),
                onPressed: () {
                  if (onCreatePressed != null) {
                    onCreatePressed!();
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('welcome.pending_flow'.tr())),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/app_icon.dart';

/// Habits-tab app bar: emerald beacon, StarNyx wordmark, and the profile
/// affordance that opens Settings.
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    required this.onProfilePressed,
    this.onSearchPressed,
    super.key,
  });

  final VoidCallback? onProfilePressed;
  final VoidCallback? onSearchPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.xs,
        AppSpacing.pageHorizontal,
        AppSpacing.xs,
      ),
      child: SizedBox(
        height: 48,
        child: Row(
          children: <Widget>[
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.6),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'app.title'.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontFamily: AppFonts.headline,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            if (onSearchPressed != null) ...<Widget>[
              _CircleActionButton(
                buttonKey: const Key('home-search-button'),
                icon: HugeIconsStrokeRounded.strokeRoundedSearch01,
                semanticsLabel: 'home.search_semantics'.tr(),
                onPressed: onSearchPressed,
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            _ProfileButton(onPressed: onProfilePressed),
          ],
        ),
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.buttonKey,
    required this.icon,
    required this.semanticsLabel,
    required this.onPressed,
  });

  final Key buttonKey;
  final List<List<dynamic>> icon;
  final String semanticsLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: buttonKey,
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox.square(
            dimension: 44,
            child: Center(
              child: AppIcon(
                icon: icon,
                size: 22,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'home.profile_semantics'.tr(),
      // 36px avatar, 44px tap target around it.
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: SizedBox.square(
          dimension: 44,
          child: Center(
            child: Material(
              color: AppColors.primary,
              shape: const CircleBorder(),
              child: InkWell(
                key: const Key('home-profile-button'),
                onTap: onPressed,
                customBorder: const CircleBorder(),
                child: const SizedBox.square(
                  dimension: 36,
                  child: Center(
                    child: AppIcon(
                      icon: HugeIconsStrokeRounded.strokeRoundedUser,
                      size: 20,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

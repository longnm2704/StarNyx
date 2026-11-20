import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:starnyx/core/constants/core_constants.dart';

import 'app_icon.dart';

/// Emerald 36px avatar in a 44px tap target; opens Settings from tab headers.
class AppProfileButton extends StatelessWidget {
  const AppProfileButton({required this.onPressed, super.key, this.inkKey});

  final VoidCallback? onPressed;

  /// Key on the InkWell, for tests that tap the avatar itself.
  final Key? inkKey;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'home.profile_semantics'.tr(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: SizedBox.square(
          dimension: AppSize.iconButton,
          child: Center(
            child: Material(
              color: AppColors.primary,
              shape: const CircleBorder(),
              child: InkWell(
                key: inkKey,
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

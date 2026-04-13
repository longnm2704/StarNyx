import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';

class WelcomeHeroIcon extends StatelessWidget {
  const WelcomeHeroIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSvgIcon(
      assetPath: 'assets/icons/ic_heart.svg',
      size: 72,
      color: AppColors.accentLavender.withValues(alpha: 0.98),
      semanticsLabel: 'welcome.heart'.tr(),
    );
  }
}

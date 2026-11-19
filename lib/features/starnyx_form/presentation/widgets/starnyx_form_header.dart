import 'package:flutter/material.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:starnyx/core/constants/core_constants.dart';

/// Page header: round leading button (close X by default), centered title.
class StarnyxFormHeader extends StatelessWidget {
  const StarnyxFormHeader({
    required this.title,
    required this.onClosePressed,
    super.key,
    this.leadingIcon = HugeIconsStrokeRounded.strokeRoundedCancel01,
    this.leadingTooltip,
  });

  final String title;
  final VoidCallback onClosePressed;
  final List<List<dynamic>> leadingIcon;
  final String? leadingTooltip;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: AppSize.iconButton,
          height: AppSize.iconButton,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceLevel2,
          ),
          child: IconButton(
            key: const Key('starnyx-form-close'),
            tooltip: leadingTooltip,
            onPressed: onClosePressed,
            icon: AppIcon(
              icon: leadingIcon,
              size: 20,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFamily: AppFonts.headline,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        // Balances the leading button so the title stays centered.
        const SizedBox(width: AppSize.iconButton),
      ],
    );
  }
}

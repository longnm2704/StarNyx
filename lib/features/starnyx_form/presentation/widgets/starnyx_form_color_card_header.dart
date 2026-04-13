import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_color_utils.dart';

class StarnyxFormColorCardHeader extends StatelessWidget {
  const StarnyxFormColorCardHeader({required this.selectedColor, super.key});

  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          'starnyx_form.selected_color_label'.tr(),
          style: starnyxColorCardSectionTitleStyle(context),
        ),
        StarnyxSelectedColorPreview(color: selectedColor),
      ],
    );
  }
}

class StarnyxSelectedColorPreview extends StatelessWidget {
  const StarnyxSelectedColorPreview({required this.color, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.previewOuter, width: 1.8),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.previewInner, width: 1.2),
          color: color,
        ),
      ),
    );
  }
}

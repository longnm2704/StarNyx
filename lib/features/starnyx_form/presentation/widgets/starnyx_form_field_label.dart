import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';

class StarnyxFormFieldLabel extends StatelessWidget {
  const StarnyxFormFieldLabel({required this.label, super.key, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontSize: 17,
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w700,
    );

    if (trailing == null) {
      return Text(label, style: textStyle);
    }

    return Row(
      children: <Widget>[
        Expanded(child: Text(label, style: textStyle)),
        const SizedBox(width: AppSpacing.sm),
        trailing!,
      ],
    );
  }
}

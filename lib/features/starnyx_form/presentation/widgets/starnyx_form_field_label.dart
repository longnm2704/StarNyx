import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';

class StarnyxFormFieldLabel extends StatelessWidget {
  const StarnyxFormFieldLabel({required this.label, super.key, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontFamily: AppFonts.body,
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label, style: textStyle)),
          if (trailing != null) ...<Widget>[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ],
        ],
      ),
    );
  }
}

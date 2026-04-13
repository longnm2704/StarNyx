import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';

class StarnyxFormFieldLabel extends StatelessWidget {
  const StarnyxFormFieldLabel({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontSize: 17,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

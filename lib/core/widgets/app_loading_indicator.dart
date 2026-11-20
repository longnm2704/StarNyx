import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';

// Shared loading widget: centered page/section spinner, or [small] for an
// 18px spinner inside a button.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key, this.label})
    : color = AppColors.primary,
      _small = false;

  const AppLoadingIndicator.small({super.key, this.color = AppColors.primary})
    : label = null,
      _small = true;

  final String? label;
  final Color color;
  final bool _small;

  @override
  Widget build(BuildContext context) {
    if (_small) {
      return SizedBox.square(
        dimension: 18,
        child: CircularProgressIndicator(strokeWidth: 2, color: color),
      );
    }

    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircularProgressIndicator(color: color),
          if (label != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Text(
              label!,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

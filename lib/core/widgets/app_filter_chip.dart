import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';

/// Pill filter chip for category rows (symbol picker, onboarding templates).
/// Selected: [color] tint with a 40% border; unselected: `#121215` with a
/// hairline. 44px minimum height for the tap target.
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
    this.color = AppColors.primary,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: Semantics(
        selected: selected,
        button: true,
        child: Material(
          color: selected
              ? color.withValues(alpha: 0.12)
              : AppColors.surfaceLevel2,
          shape: StadiumBorder(
            side: BorderSide(
              color: selected
                  ? color.withValues(alpha: 0.4)
                  : AppColors.borderSubtle,
            ),
          ),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: AppSize.iconButton),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: selected ? color : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
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

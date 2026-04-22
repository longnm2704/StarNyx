import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';

// Primary CTA used throughout the StarNyx mockups.
class GradientOutlineButton extends StatelessWidget {
  const GradientOutlineButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.height = AppSize.ctaHeight,
  });

  final String label;
  final VoidCallback onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.accentPink.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppColors.accentFillGradient,
            borderRadius: BorderRadius.circular(AppRadius.pill - 1.4),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.pill - 1.4),
              onTap: onPressed,
              child: SizedBox(
                width: double.infinity,
                height: height,
                child: Center(
                  child: Text(
                    label,
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.accentLavender,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.15,
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

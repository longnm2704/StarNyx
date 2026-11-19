import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';

enum AppPrimaryButtonVariant { primary, ghost }

// Primary CTA used throughout the StarNyx mockups.
//
// Primary: pill, `#10B981` fill, black w700 label, 52px height, pressed
// scale 0.98 with a soft emerald glow. Ghost: `#0A0A0C` fill, hairline
// border, `#F9FAFB` label.
class AppPrimaryButton extends StatefulWidget {
  const AppPrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = AppPrimaryButtonVariant.primary,
    this.height = AppSize.ctaHeight,
  });

  final String label;
  final VoidCallback onPressed;
  final AppPrimaryButtonVariant variant;
  final double height;

  @override
  State<AppPrimaryButton> createState() => _AppPrimaryButtonState();
}

class _AppPrimaryButtonState extends State<AppPrimaryButton> {
  bool _pressed = false;

  bool get _isPrimary => widget.variant == AppPrimaryButtonVariant.primary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final Color fill = _isPrimary ? AppColors.primary : AppColors.surfaceLevel1;
    final Color labelColor = _isPrimary ? AppColors.onPrimary : AppColors.textPrimary;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: _isPrimary
                ? null
                : Border.all(color: AppColors.borderSubtle),
            boxShadow: _isPrimary
                ? const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x2610B981), // rgba(16,185,129,0.15)
                      blurRadius: 24,
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              onTap: widget.onPressed,
              child: SizedBox(
                width: double.infinity,
                height: widget.height,
                child: Center(
                  child: Text(
                    widget.label,
                    style: textTheme.titleMedium?.copyWith(
                      color: labelColor,
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

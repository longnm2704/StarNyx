import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';

import 'app_icon.dart';
import 'app_loading_indicator.dart';

/// primary: emerald fill. ghost: `#0A0A0C` + hairline. dark: black +
/// hairline (secondary actions on a card). destructive: coral fill.
enum AppPrimaryButtonVariant { primary, ghost, dark, destructive }

// Primary CTA used throughout the StarNyx mockups.
//
// Primary: pill, `#10B981` fill, black w700 label, 52px height, pressed
// scale 0.98 with a soft emerald glow. Ghost: `#0A0A0C` fill, hairline
// border, `#F9FAFB` label. A null [onPressed] renders the disabled state;
// [isLoading] keeps the variant colors, swaps the [icon] for a spinner and
// ignores taps.
class AppPrimaryButton extends StatefulWidget {
  const AppPrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = AppPrimaryButtonVariant.primary,
    this.height = AppSize.ctaHeight,
    this.icon,
    this.isLoading = false,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppPrimaryButtonVariant variant;
  final double height;
  final List<List<dynamic>>? icon;
  final bool isLoading;

  /// Overrides the variant's label/icon color (e.g. an emerald label on a
  /// [AppPrimaryButtonVariant.dark] button).
  final Color? foregroundColor;

  @override
  State<AppPrimaryButton> createState() => _AppPrimaryButtonState();
}

class _AppPrimaryButtonState extends State<AppPrimaryButton> {
  bool _pressed = false;

  bool get _isPrimary => widget.variant == AppPrimaryButtonVariant.primary;
  bool get _enabled => widget.onPressed != null || widget.isLoading;
  VoidCallback? get _onTap => widget.isLoading ? null : widget.onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final (
      Color fill,
      Color variantLabel,
      bool outlined,
    ) = switch (widget.variant) {
      AppPrimaryButtonVariant.primary => (
        AppColors.primary,
        AppColors.onPrimary,
        false,
      ),
      AppPrimaryButtonVariant.ghost => (
        AppColors.surfaceLevel1,
        AppColors.textPrimary,
        true,
      ),
      AppPrimaryButtonVariant.dark => (
        AppColors.black,
        AppColors.textPrimary,
        true,
      ),
      AppPrimaryButtonVariant.destructive => (
        AppColors.error,
        AppColors.black,
        false,
      ),
    };
    final Color labelColor = !_enabled
        ? AppColors.textTertiary
        : widget.foregroundColor ?? variantLabel;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = _onTap != null),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _enabled ? fill : AppColors.surfaceLevel3,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: outlined ? Border.all(color: AppColors.borderSubtle) : null,
            boxShadow: _isPrimary && _enabled
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
              onTap: _onTap,
              // Min height so large text scales grow the pill instead of
              // clipping the label.
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: double.infinity,
                  minHeight: widget.height,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xs,
                  ),
                  child: Center(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (widget.isLoading)
                          AppLoadingIndicator.small(color: labelColor)
                        else if (widget.icon != null)
                          AppIcon(
                            icon: widget.icon!,
                            size: 18,
                            color: labelColor,
                          ),
                        if (widget.isLoading || widget.icon != null)
                          const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            widget.label,
                            textAlign: TextAlign.center,
                            style: textTheme.titleMedium?.copyWith(
                              color: labelColor,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.15,
                            ),
                          ),
                        ),
                      ],
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

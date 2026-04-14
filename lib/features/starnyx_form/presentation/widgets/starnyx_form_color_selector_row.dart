import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_color_utils.dart';

class StarnyxFormColorSelectorRow extends StatelessWidget {
  const StarnyxFormColorSelectorRow({
    required this.selectedColorHex,
    required this.onColorSelected,
    required this.onCustomColorTap,
    required this.dotSize,
    required this.dotSpacing,
    super.key,
  });

  final String selectedColorHex;
  final ValueChanged<String> onColorSelected;
  final VoidCallback onCustomColorTap;
  final double dotSize;
  final double dotSpacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(children: _buildPresetDots()),
        _LockedColorDot(size: dotSize, onTap: onCustomColorTap),
      ],
    );
  }

  List<Widget> _buildPresetDots() {
    return AppColors.starnyxPresetColorHexes.asMap().entries.map((entry) {
      final index = entry.key;
      final presetHex = normalizeStarnyxHex(entry.value);
      final isLast = index == AppColors.starnyxPresetColorHexes.length - 1;

      return Padding(
        padding: EdgeInsets.only(right: isLast ? 0 : dotSpacing),
        child: _ColorDotButton(
          size: dotSize,
          color: starnyxColorFromHex(presetHex),
          isSelected: presetHex == selectedColorHex,
          onTap: () => onColorSelected(presetHex),
        ),
      );
    }).toList();
  }
}

class _ColorDotButton extends StatelessWidget {
  const _ColorDotButton({
    required this.size,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final double size;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: size,
        height: size,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(
                  color: AppColors.white.withValues(alpha: 0.92),
                  width: 2,
                )
              : null,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }
}

class _LockedColorDot extends StatelessWidget {
  const _LockedColorDot({required this.size, required this.onTap});

  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            colors: <Color>[
              AppColors.sysGreen,
              AppColors.sysBlue,
              AppColors.sysPurple,
              AppColors.sysOrange,
              AppColors.sysGreen,
            ],
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.sheetBg,
          ),
          child: const Center(
            child: AppSvgIcon(
              assetPath: 'assets/icons/ic_color_picker.svg',
              semanticsLabel: 'Color picker',
              size: 18,
              color: AppColors.lockIcon,
            ),
          ),
        ),
      ),
    );
  }
}

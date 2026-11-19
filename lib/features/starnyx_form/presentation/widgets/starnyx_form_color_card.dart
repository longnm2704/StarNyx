import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_color_picker_sheet.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_color_utils.dart';

// Localized name per preset, in [AppColors.starnyxPresetColorHexes] order.
const List<String> _kPresetNameKeys = <String>[
  'starnyx_form.color_violet',
  'starnyx_form.color_blue',
  'starnyx_form.color_amber',
  'starnyx_form.color_emerald',
];

/// "Màu sắc" section: label + selected color name chip, preset color dots
/// and a custom-color picker dot. The selected dot has a ring.
class StarnyxFormColorCard extends StatelessWidget {
  const StarnyxFormColorCard({
    required this.selectedColorHex,
    required this.onColorSelected,
    super.key,
  });

  static const double _dotSize = 44;

  final String selectedColorHex;
  final ValueChanged<String> onColorSelected;

  Future<void> _pickCustomColor(BuildContext context) async {
    final pickedColorHex = await showStarnyxFormColorPickerSheet(
      context,
      selectedColorHex,
    );
    if (pickedColorHex != null) {
      onColorSelected(pickedColorHex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedHex = normalizeStarnyxHex(selectedColorHex);
    final selectedColor = starnyxColorFromHex(selectedHex);
    final presets = AppColors.starnyxPresetColorHexes
        .map(normalizeStarnyxHex)
        .toList(growable: false);
    final presetIndex = presets.indexOf(selectedHex);
    final isCustom = presetIndex < 0;
    final colorName =
        (isCustom ? 'starnyx_form.color_custom' : _kPresetNameKeys[presetIndex])
            .tr();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLevel1,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'starnyx_form.color_label'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _ColorNameChip(color: selectedColor, name: colorName),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              for (var i = 0; i < presets.length; i++)
                _ColorDot(
                  key: Key('starnyx-form-color-${presets[i]}'),
                  size: _dotSize,
                  color: starnyxColorFromHex(presets[i]),
                  isSelected: i == presetIndex,
                  semanticsLabel: _kPresetNameKeys[i].tr(),
                  onTap: () => onColorSelected(presets[i]),
                ),
              // A custom color fills the picker dot so the selection stays
              // visible.
              _ColorDot(
                key: const Key('starnyx-form-color-custom'),
                size: _dotSize,
                color: isCustom ? selectedColor : AppColors.surfaceLevel2,
                isSelected: isCustom,
                semanticsLabel: 'starnyx_form.color_custom'.tr(),
                onTap: () => _pickCustomColor(context),
                child: AppIcon(
                  icon: HugeIconsStrokeRounded.strokeRoundedColorPicker,
                  size: 18,
                  color: isCustom ? AppColors.black : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColorNameChip extends StatelessWidget {
  const _ColorNameChip({required this.color, required this.name});

  final Color color;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, AppSpacing.sm, 6),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              name.toUpperCase(),
              key: const Key('starnyx-form-color-name'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontFamily: AppFonts.mono,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.size,
    required this.color,
    required this.isSelected,
    required this.semanticsLabel,
    required this.onTap,
    super.key,
    this.child,
  });

  final double size;
  final Color color;
  final bool isSelected;
  final String semanticsLabel;
  final VoidCallback onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          width: size,
          height: size,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? AppColors.textPrimary : Colors.transparent,
              width: 2,
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: isSelected
                  ? <BoxShadow>[
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
            ),
            child: child == null ? null : Center(child: child),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:starnyx/core/widgets/gradient_outline_button.dart';

class StarnyxFormColorCard extends StatelessWidget {
  const StarnyxFormColorCard({
    required this.selectedColorHex,
    required this.onColorSelected,
    super.key,
  });

  final String selectedColorHex;
  final ValueChanged<String> onColorSelected;

  @override
  Widget build(BuildContext context) {
    final selectedColor = _colorFromHex(selectedColorHex);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[AppColors.formCardStart, AppColors.formCardEndAlt],
        ),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.62)),
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'starnyx_form.selected_color_label'.tr(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              _SelectedColorPreview(color: selectedColor),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  for (
                    int i = 0;
                    i < AppColors.starnyxPresetColorHexes.length;
                    i++
                  )
                    Padding(
                      padding: EdgeInsets.only(
                        right: i == AppColors.starnyxPresetColorHexes.length - 1
                            ? 0
                            : 10,
                      ),
                      child: _ColorDotButton(
                        size: 40,
                        color: _colorFromHex(
                          AppColors.starnyxPresetColorHexes[i],
                        ),
                        isSelected:
                            _normalizeHex(
                              AppColors.starnyxPresetColorHexes[i],
                            ) ==
                            _normalizeHex(selectedColorHex),
                        onTap: () => onColorSelected(
                          _normalizeHex(AppColors.starnyxPresetColorHexes[i]),
                        ),
                      ),
                    ),
                ],
              ),
              Row(
                children: <Widget>[
                  _LockedColorDot(
                    size: 40,
                    onTap: () async {
                      final pickedColorHex = await _showColorPickerSheet(
                        context,
                        selectedColorHex,
                      );
                      if (pickedColorHex != null) {
                        onColorSelected(pickedColorHex);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SelectedColorPreview extends StatelessWidget {
  const _SelectedColorPreview({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.previewOuter, width: 1.8),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.previewInner, width: 1.2),
          color: color,
        ),
      ),
    );
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
          child: const Icon(
            Icons.lock_outline_rounded,
            size: 20,
            color: AppColors.lockIcon,
          ),
        ),
      ),
    );
  }
}

Future<String?> _showColorPickerSheet(
  BuildContext context,
  String selectedColorHex,
) {
  Color editingColor = _colorFromHex(selectedColorHex);

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            padding: EdgeInsets.fromLTRB(
              20,
              18,
              20,
              16 + MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: AppColors.sheetBg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border.all(
                color: AppColors.outline.withValues(alpha: 0.62),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'starnyx_form.selected_color_label'.tr(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ColorPicker(
                    pickerColor: editingColor,
                    onColorChanged: (Color value) {
                      setState(() {
                        editingColor = value;
                      });
                    },
                    enableAlpha: false,
                    paletteType: PaletteType.hsvWithHue,
                    displayThumbColor: true,
                    labelTypes: const <ColorLabelType>[],
                    pickerAreaHeightPercent: 0.6,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: GradientOutlineButton(
                      label: 'starnyx_form.picker_done'.tr(),
                      onPressed: () {
                        Navigator.of(context).pop(_hexFromColor(editingColor));
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Color _colorFromHex(String hex) {
  final normalized = _normalizeHex(hex).replaceFirst('#', '');
  return Color(int.parse('FF$normalized', radix: 16));
}

String _normalizeHex(String value) {
  final normalized = value.trim().toUpperCase();
  if (normalized.startsWith('#') && normalized.length == 7) {
    return normalized;
  }

  if (normalized.length == 6) {
    return '#$normalized';
  }

  return '#AF2395';
}

String _hexFromColor(Color color) {
  final rgb = color.toARGB32() & 0x00FFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

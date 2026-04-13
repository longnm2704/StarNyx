import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_color_utils.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_color_card_header.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_color_picker_sheet.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_color_selector_row.dart';

class StarnyxFormColorCard extends StatelessWidget {
  const StarnyxFormColorCard({
    required this.selectedColorHex,
    required this.onColorSelected,
    super.key,
  });

  static const double _dotSize = 40;
  static const double _dotSpacing = 10;

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
    final normalizedSelectedHex = normalizeStarnyxHex(selectedColorHex);
    final selectedColor = starnyxColorFromHex(selectedColorHex);

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
          StarnyxFormColorCardHeader(selectedColor: selectedColor),
          const SizedBox(height: AppSpacing.sm),
          StarnyxFormColorSelectorRow(
            selectedColorHex: normalizedSelectedHex,
            onColorSelected: onColorSelected,
            onCustomColorTap: () => _pickCustomColor(context),
            dotSize: _dotSize,
            dotSpacing: _dotSpacing,
          ),
        ],
      ),
    );
  }
}

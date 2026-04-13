import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:starnyx/core/widgets/gradient_outline_button.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_color_utils.dart';

Future<String?> showStarnyxFormColorPickerSheet(
  BuildContext context,
  String initialColorHex,
) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        _StarnyxFormColorPickerSheet(initialColorHex: initialColorHex),
  );
}

class _StarnyxFormColorPickerSheet extends StatefulWidget {
  const _StarnyxFormColorPickerSheet({required this.initialColorHex});

  final String initialColorHex;

  @override
  State<_StarnyxFormColorPickerSheet> createState() =>
      _StarnyxFormColorPickerSheetState();
}

class _StarnyxFormColorPickerSheetState
    extends State<_StarnyxFormColorPickerSheet> {
  late Color editingColor;

  @override
  void initState() {
    super.initState();
    editingColor = starnyxColorFromHex(widget.initialColorHex);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        18,
        20,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.62)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'starnyx_form.selected_color_label'.tr(),
              style: starnyxColorCardSectionTitleStyle(context),
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
                  Navigator.of(context).pop(starnyxHexFromColor(editingColor));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:starnyx/core/widgets/app_sheet.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_color_utils.dart';

Future<String?> showStarnyxFormColorPickerSheet(
  BuildContext context,
  String initialColorHex,
) {
  var editingColor = starnyxColorFromHex(initialColorHex);

  return showAppSheet<String>(
    context: context,
    title: 'starnyx_form.selected_color_label'.tr(),
    doneLabel: 'starnyx_form.picker_done'.tr(),
    onDone: () => starnyxHexFromColor(editingColor),
    // ponytail: ColorPicker keeps its own state; the closure only records it.
    child: ColorPicker(
      pickerColor: editingColor,
      onColorChanged: (Color value) => editingColor = value,
      enableAlpha: false,
      paletteType: PaletteType.hsvWithHue,
      displayThumbColor: true,
      labelTypes: const <ColorLabelType>[],
      pickerAreaHeightPercent: 0.6,
    ),
  );
}

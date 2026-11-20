import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:starnyx/core/widgets/app_sheet.dart';

// Time or date wheel in the shared sheet; digits come from the theme's
// `cupertinoOverrideTheme` (mono, tabular figures).
Future<DateTime?> showStarnyxCupertinoDateTimePicker({
  required BuildContext context,
  required CupertinoDatePickerMode mode,
  required DateTime initialDateTime,
  DateTime? minimumDate,
  DateTime? maximumDate,
}) {
  var selectedDateTime = initialDateTime;

  return showAppSheet<DateTime>(
    context: context,
    title:
        (mode == CupertinoDatePickerMode.date
                ? 'starnyx_form.start_on_label'
                : 'starnyx_form.reminder_time_label')
            .tr(),
    doneLabel: 'starnyx_form.picker_done'.tr(),
    onDone: () => selectedDateTime,
    child: SizedBox(
      height: 216,
      child: CupertinoDatePicker(
        mode: mode,
        initialDateTime: initialDateTime,
        minimumDate: minimumDate,
        maximumDate: maximumDate,
        use24hFormat: true,
        onDateTimeChanged: (DateTime value) => selectedDateTime = value,
      ),
    ),
  );
}

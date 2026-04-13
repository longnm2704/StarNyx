import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:starnyx/core/constants/core_constants.dart';

Future<DateTime?> showStarnyxCupertinoDateTimePicker({
  required BuildContext context,
  required CupertinoDatePickerMode mode,
  required DateTime initialDateTime,
  DateTime? minimumDate,
  DateTime? maximumDate,
}) {
  DateTime selectedDateTime = initialDateTime;
  final mediaQuery = MediaQuery.of(context);

  return showCupertinoModalPopup<DateTime>(
    context: context,
    builder: (BuildContext popupContext) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 320 + mediaQuery.viewPadding.bottom,
          padding: EdgeInsets.only(bottom: mediaQuery.viewPadding.bottom),
          decoration: const BoxDecoration(
            color: AppColors.pickerBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 46,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    CupertinoButton(
                      onPressed: () {
                        Navigator.of(popupContext).pop(selectedDateTime);
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'starnyx_form.picker_done'.tr(),
                        style: const TextStyle(
                          color: AppColors.accentLavender,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.outline.withValues(alpha: 0.5),
              ),
              Expanded(
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    brightness: Brightness.dark,
                    primaryColor: AppColors.accentLavender,
                    scaffoldBackgroundColor: AppColors.pickerBg,
                  ),
                  child: CupertinoDatePicker(
                    mode: mode,
                    initialDateTime: initialDateTime,
                    minimumDate: minimumDate,
                    maximumDate: maximumDate,
                    use24hFormat: true,
                    onDateTimeChanged: (DateTime value) {
                      selectedDateTime = value;
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

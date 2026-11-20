import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';

import 'app_primary_button.dart';

/// Shows the shared bottom sheet: theme sheet surface, drag handle, radius
/// and hairline (see `bottomSheetTheme`), a headline [title] and [child].
///
/// With [doneLabel], a solid Done pill pops the sheet with [onDone]'s value.
Future<T?> showAppSheet<T>({
  required BuildContext context,
  required String title,
  required Widget child,
  String? doneLabel,
  T Function()? onDone,
  Key? key,
  Key? doneKey,
  bool useRootNavigator = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: useRootNavigator,
    builder: (sheetContext) => Padding(
      key: key,
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(sheetContext).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              child,
              if (doneLabel != null) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                AppPrimaryButton(
                  key: doneKey,
                  label: doneLabel,
                  onPressed: () =>
                      Navigator.of(sheetContext).pop(onDone?.call()),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

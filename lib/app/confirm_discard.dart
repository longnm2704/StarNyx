import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:starnyx/core/widgets/core_widgets.dart';

/// Asks before leaving a screen with unsaved edits. True means discard.
Future<bool> confirmDiscardChanges(BuildContext context) async {
  final confirmed = await showAppConfirmDialog(
    context: context,
    title: 'app.discard_title'.tr(),
    message: 'app.discard_message'.tr(),
    cancelLabel: 'app.discard_cancel'.tr(),
    confirmLabel: 'app.discard_confirm'.tr(),
    icon: HugeIconsStrokeRounded.strokeRoundedAlert01,
  );
  return confirmed ?? false;
}

/// [PopScope] that lets the route go freely while [dirty] is false, and
/// otherwise confirms with [confirmDiscardChanges] first.
class DiscardChangesScope extends StatelessWidget {
  const DiscardChangesScope({
    required this.dirty,
    required this.child,
    super.key,
  });

  final bool dirty;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: !dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await confirmDiscardChanges(context) && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: child,
    );
  }
}

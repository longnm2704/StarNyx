import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:starnyx/core/services/core_services.dart';

/// Asks for notification permission when the user turns a reminder on
/// (never at launch). When it is denied, a calm snackbar explains that
/// reminders need it in system settings. The reminder itself stays on, so it
/// starts showing once the user allows notifications.
Future<bool> requestReminderPermission(BuildContext context) async {
  if (!serviceLocator.isRegistered<NotificationService>()) return true;
  final messenger = ScaffoldMessenger.maybeOf(context);
  bool granted;
  try {
    granted = await serviceLocator<NotificationService>().requestPermission();
  } catch (_) {
    // Platform hiccup: don't block the user over it.
    return true;
  }
  if (!granted) {
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('settings.reminders_permission_denied'.tr())),
      );
  }
  return granted;
}

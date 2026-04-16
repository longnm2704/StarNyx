import 'package:flutter/widgets.dart';
import 'package:starnyx/app/app.dart';
import 'package:starnyx/core/services/core_services.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:easy_localization/easy_localization.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Register app-level dependencies before any widget tree needs them.
  await configureDependencies();
  await serviceLocator<NotificationService>().initialize();
  // Localization must be initialized before EasyLocalization wraps the app.
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      useOnlyLangCode: true,
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      supportedLocales: const <Locale>[Locale('en')],
      child: const StarNyxApp(),
    ),
  );
}

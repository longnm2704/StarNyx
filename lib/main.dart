import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:starnyx/app/app.dart';
import 'package:starnyx/app/app_bloc_observer.dart';
import 'package:starnyx/core/services/core_services.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:easy_localization/easy_localization.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Register app-level dependencies before any widget tree needs them.
  await configureDependencies();
  final logger = serviceLocator<AppLogService>();
  Bloc.observer = AppBlocObserver(logger);
  logger.debug('Bootstrap', 'dependencies configured');
  await serviceLocator<NotificationService>().initialize();
  logger.debug('Bootstrap', 'notification service initialized');
  // Localization must be initialized before EasyLocalization wraps the app.
  await EasyLocalization.ensureInitialized();
  logger.debug('Bootstrap', 'localization initialized');

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

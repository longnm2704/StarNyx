import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:starnyx/core/utils/backup_file_codec.dart';
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
  final notifications = serviceLocator<NotificationService>();
  await notifications.initialize();
  logger.debug('Bootstrap', 'notification service initialized');
  // Localization must be initialized before EasyLocalization wraps the app.
  await EasyLocalization.ensureInitialized();
  logger.debug('Bootstrap', 'localization initialized');
  // Reminder copy uses the global translator, which always reads the current
  // locale: no widget context to outlive (Settings, onboarding, delete-all).
  notifications.setTranslator(
    (key, {namedArgs}) => tr(
      key,
      namedArgs: namedArgs?.map((k, v) => MapEntry<String, String>(k, '$v')),
    ),
  );

  // Exports from earlier sessions may still sit in the temp dir (a shared
  // file is only deleted at the next export). Fire and forget: never delays
  // the first frame, and the helper logs its own failures.
  unawaited(
    getTemporaryDirectory()
        .then((dir) => deleteStaleBackupExports(dir, logger: logger))
        .catchError(
          (Object error, StackTrace stackTrace) => logger.error(
            'Bootstrap',
            'temp dir unavailable for export cleanup',
            error: error,
            stackTrace: stackTrace,
          ),
        ),
  );

  runApp(
    EasyLocalization(
      useOnlyLangCode: true,
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      supportedLocales: const <Locale>[
        Locale('en'),
        Locale('vi'),
        Locale('ja'),
      ],
      child: const StarNyxApp(),
    ),
  );
}

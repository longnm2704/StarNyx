import 'package:flutter/material.dart';
import 'package:starnyx/app/theme/app_theme.dart';
import 'package:starnyx/app/router/app_router.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:easy_localization/easy_localization.dart';

// Root app widget that wires theme, localization, and navigation together.
class StarNyxApp extends StatelessWidget {
  const StarNyxApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Router comes from DI so later route guards or feature modules stay centralized.
    final router = serviceLocator<AppRouter>();

    return MaterialApp(
      locale: context.locale,
      theme: AppTheme.dark(),
      initialRoute: AppRoutes.home,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: router.onGenerateRoute,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      onGenerateTitle: (BuildContext context) => 'app.title'.tr(),
    );
  }
}

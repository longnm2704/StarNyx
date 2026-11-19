import 'package:flutter/material.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:starnyx/app/shell/app_shell.dart';
import 'package:starnyx/core/services/core_services.dart';

abstract final class AppRoutes {
  static const habits = '/habits';
  static const overview = '/overview';
  static const journal = '/journal';
  static const settings = '/settings';

  /// Legacy alias kept for existing call sites; the shell always opens Habits.
  static const home = habits;

  static AppShellTab tabForRoute(String? name) {
    return switch (name) {
      overview => AppShellTab.overview,
      journal => AppShellTab.journal,
      settings => AppShellTab.settings,
      _ => AppShellTab.habits,
    };
  }
}

class AppRouter {
  const AppRouter();

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // Every top-level destination is hosted by the same shell route so tab
    // state is preserved and deep links simply choose the initial tab.
    return MaterialPageRoute<void>(
      builder: (_) => AppShell(
        initialTab: AppRoutes.tabForRoute(settings.name),
        initialAccentColor: serviceLocator<ActiveStarnyxColorCache>()
            .readColor(),
      ),
      settings: settings,
    );
  }
}

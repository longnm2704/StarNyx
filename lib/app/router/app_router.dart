import 'package:flutter/material.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:starnyx/app/router/app_routes.dart';
import 'package:starnyx/app/shell/app_shell.dart';
import 'package:starnyx/core/services/core_services.dart';
import 'package:starnyx/features/habits/presentation/pages/habit_list_page.dart';

export 'app_routes.dart';

/// Maps a deep-link / named route to the tab the shell should open.
AppShellTab appShellTabForRoute(String? name) {
  return switch (name) {
    AppRoutes.overview => AppShellTab.overview,
    AppRoutes.journal => AppShellTab.journal,
    AppRoutes.settings => AppShellTab.settings,
    _ => AppShellTab.habits,
  };
}

class AppRouter {
  const AppRouter();

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (settings.name == AppRoutes.habitList) {
      return MaterialPageRoute<HabitListExitAction>(
        builder: (_) => const HabitListPage(),
        settings: settings,
      );
    }

    // Every top-level destination is hosted by the same shell route so tab
    // state is preserved and deep links simply choose the initial tab.
    return MaterialPageRoute<void>(
      builder: (_) => AppShell(
        initialTab: appShellTabForRoute(settings.name),
        initialAccentColor: serviceLocator<ActiveStarnyxColorCache>()
            .readColor(),
      ),
      settings: settings,
    );
  }
}

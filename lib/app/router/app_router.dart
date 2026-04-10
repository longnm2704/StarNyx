import 'package:flutter/material.dart';
import 'package:starnyx/features/home/presentation/pages/home_page.dart';

abstract final class AppRoutes {
  static const home = '/';
}

class AppRouter {
  const AppRouter();

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // Centralizing route creation here keeps MaterialApp simple and gives us one place to add route arguments, guards, and feature modules later.
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute<void>(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const HomePage(),
          settings: settings,
        );
    }
  }
}

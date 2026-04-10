import 'package:flutter/material.dart';

// Central theme entrypoint for the current light-mode visual baseline.
abstract final class AppTheme {
  static ThemeData light() {
    const seedColor = Color(0xFF1D3557);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
      scaffoldBackgroundColor: const Color(0xFFF7F8FB),
      appBarTheme: const AppBarTheme(centerTitle: false),
    );
  }
}

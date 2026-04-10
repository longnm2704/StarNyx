import 'package:flutter/material.dart';

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

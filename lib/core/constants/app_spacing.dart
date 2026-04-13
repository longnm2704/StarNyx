import 'package:flutter/widgets.dart';

// Shared spacing scale and insets used across the app.
abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;

  static const pageHorizontal = 20.0;
  static const pageVertical = 24.0;
  static const section = 24.0;

  static const cardPadding = EdgeInsets.all(lg);
  static const sheetPadding = EdgeInsets.all(lg);
  static const pagePadding = EdgeInsets.symmetric(
    horizontal: pageHorizontal,
    vertical: pageVertical,
  );
  static const inputContentPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: md,
  );
}

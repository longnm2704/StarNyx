import 'package:flutter/material.dart';

// Obsidian Lumina palette (docs/app_ui_redesign/obsidian_lumina/DESIGN.md).
abstract final class AppColors {
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);

  // Base canvas and tonal surface tiers (no gradients, hairline borders).
  static const background = Color(0xFF000000);
  static const surfaceLevel1 = Color(0xFF0A0A0C);
  static const surfaceLevel2 = Color(0xFF121215);
  static const surfaceLevel3 = Color(0xFF1A1A1F);
  static const sheet = Color(0xFF16161A);

  static const borderSubtle = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const borderFocus = Color(0x2EFFFFFF); // rgba(255,255,255,0.18)

  static const textPrimary = Color(0xFFF9FAFB);
  static const textSecondary = Color(0xFF9CA3AF);
  static const textTertiary = Color(0xFF4B5563);

  static const primary = Color(0xFF10B981);
  static const onPrimary = Color(0xFF000000);
  static const secondary = Color(0xFF06B6D4);
  static const onSecondary = Color(0xFF000000);
  static const tertiary = Color(0xFFF59E0B);
  static const onTertiary = Color(0xFF000000);

  static const error = Color(0xFFF43F5E);
  static const errorOnDark = Color(0xFFFFB4AB);

  static const List<String> starnyxPresetColorHexes = <String>[
    '#9D50FF',
    '#2563EB',
    '#FFB95F',
    '#10B981',
  ];
}

import 'package:flutter/material.dart';

// Obsidian Lumina palette (docs/app_ui_redesign/obsidian_lumina/DESIGN.md).
//
// Legacy cosmic tokens are kept only so existing call sites keep compiling
// while the redesign lands; they are @Deprecated and must not be referenced
// by new code. They are removed in STX-U005 once no caller remains.
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

  // ---------------------------------------------------------------------------
  // Legacy cosmic tokens — @Deprecated, do not use in new code.
  // Migration: backgroundMid/backgroundBottom/screenGradient -> background;
  // surface/surfaceMuted -> surfaceLevel1/surfaceLevel2; surfaceElevated ->
  // surfaceLevel3; surfaceGlass/sheetBg -> sheet; outline/outlineSoft ->
  // borderSubtle/borderFocus; textMuted -> textTertiary; accentBlue ->
  // secondary; accentViolet/accentPink/accentLavender -> primary; accentOrange ->
  // tertiary; star/starMuted -> surfaceLevel2/surfaceLevel3; formCard*/pickerBg
  // -> surfaceLevel2/surfaceLevel3; sheetTop/sheetMid -> sheet; sysGreen ->
  // primary; sysBlue -> secondary; sysPurple -> primary; sysOrange -> tertiary;
  // accentGradient/accentFillGradient -> removed (no gradients).
  // ---------------------------------------------------------------------------

  @Deprecated('Use AppColors.background. Will be removed in STX-U005.')
  static const backgroundMid = Color(0xFF1A0D2E);
  @Deprecated('Use AppColors.background. Will be removed in STX-U005.')
  static const backgroundBottom = Color(0xFF6A38A5);

  @Deprecated('Use AppColors.surfaceLevel1. Will be removed in STX-U005.')
  static const surface = Color(0xFF26222E);
  @Deprecated('Use AppColors.surfaceLevel3. Will be removed in STX-U005.')
  static const surfaceElevated = Color(0xFF332E3D);
  @Deprecated('Use AppColors.surfaceLevel2. Will be removed in STX-U005.')
  static const surfaceMuted = Color(0xFF1D1826);
  @Deprecated('Use AppColors.sheet. Will be removed in STX-U005.')
  static const surfaceGlass = Color(0xFF231D31);
  @Deprecated('Use AppColors.borderSubtle. Will be removed in STX-U005.')
  static const outline = Color(0xFF5E5470);
  @Deprecated('Use AppColors.borderFocus. Will be removed in STX-U005.')
  static const outlineSoft = Color(0xFF7B6E93);

  @Deprecated('Use AppColors.textTertiary. Will be removed in STX-U005.')
  static const textMuted = Color(0xFF9988B1);

  @Deprecated('Use AppColors.secondary. Will be removed in STX-U005.')
  static const accentBlue = Color(0xFF4A86FF);
  @Deprecated('Use AppColors.primary. Will be removed in STX-U005.')
  static const accentViolet = Color(0xFF8E5BFF);
  @Deprecated('Use AppColors.primary. Will be removed in STX-U005.')
  static const accentPink = Color(0xFFD875FF);
  @Deprecated('Use AppColors.primary. Will be removed in STX-U005.')
  static const accentLavender = Color(0xFFE1BCFF);
  @Deprecated('Use AppColors.tertiary. Will be removed in STX-U005.')
  static const accentOrange = Color(0xFFDA7A31);

  @Deprecated('Use AppColors.surfaceLevel2. Will be removed in STX-U005.')
  static const star = Color(0xFF5B3C89);
  @Deprecated('Use AppColors.surfaceLevel3. Will be removed in STX-U005.')
  static const starMuted = Color(0xFF2A173F);

  @Deprecated('Use AppColors.surfaceLevel2. Will be removed in STX-U005.')
  static const formCardStart = Color(0xFF1F2024);
  @Deprecated('Use AppColors.surfaceLevel3. Will be removed in STX-U005.')
  static const formCardEnd = Color(0xFF28292F);
  @Deprecated('Use AppColors.surfaceLevel3. Will be removed in STX-U005.')
  static const formCardEndAlt = Color(0xFF292A30);

  @Deprecated('Use AppColors.surfaceLevel2. Will be removed in STX-U005.')
  static const pickerBg = Color(0xFF1A1526);
  @Deprecated('Use AppColors.sheet. Will be removed in STX-U005.')
  static const sheetBg = Color(0xFF1A1523);
  @Deprecated('Use AppColors.surfaceLevel3. Will be removed in STX-U005.')
  static const switchTrack = Color(0xFF666874);
  @Deprecated('Use AppColors.textTertiary. Will be removed in STX-U005.')
  static const iconMuted = Color(0xFFA7A8AF);

  @Deprecated('Use AppColors.borderFocus. Will be removed in STX-U005.')
  static const previewOuter = Color(0xFF9C9EA8);
  @Deprecated('Use AppColors.textSecondary. Will be removed in STX-U005.')
  static const previewInner = Color(0xFFCFD0D6);
  @Deprecated('Use AppColors.textPrimary. Will be removed in STX-U005.')
  static const lockIcon = Color(0xFFE6DFF2);

  @Deprecated('Use AppColors.sheet. Will be removed in STX-U005.')
  static const sheetTop = Color(0xFF5B30A2);
  @Deprecated('Use AppColors.sheet. Will be removed in STX-U005.')
  static const sheetMid = Color(0xFF2A1F59);

  @Deprecated('Use AppColors.primary. Will be removed in STX-U005.')
  static const sysGreen = Color(0xFF35C759);
  @Deprecated('Use AppColors.secondary. Will be removed in STX-U005.')
  static const sysBlue = Color(0xFF0A84FF);
  @Deprecated('Use AppColors.primary. Will be removed in STX-U005.')
  static const sysPurple = Color(0xFFAF52DE);
  @Deprecated('Use AppColors.tertiary. Will be removed in STX-U005.')
  static const sysOrange = Color(0xFFFF9F0A);

  @Deprecated('Gradients are removed in Obsidian Lumina. Will be removed in STX-U005.')
  static const screenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[background, background, backgroundMid, backgroundBottom],
    stops: <double>[0.0, 0.34, 0.74, 1.0],
  );

  @Deprecated('Gradients are removed in Obsidian Lumina. Will be removed in STX-U005.')
  static const accentGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[accentBlue, accentViolet, accentPink],
  );

  @Deprecated('Gradients are removed in Obsidian Lumina. Will be removed in STX-U005.')
  static const accentFillGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[Color(0xFF354E88), Color(0xFF4B3884), Color(0xFF7E439B)],
  );
}

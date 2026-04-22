import 'package:flutter/material.dart';

// Shared cosmic palette derived from the approved StarNyx UI mockups.
abstract final class AppColors {
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);

  static const background = Color(0xFF05030A);
  static const backgroundMid = Color(0xFF1A0D2E);
  static const backgroundBottom = Color(0xFF6A38A5);

  static const surface = Color(0xFF26222E);
  static const surfaceElevated = Color(0xFF332E3D);
  static const surfaceMuted = Color(0xFF1D1826);
  static const surfaceGlass = Color(0xFF231D31);
  static const outline = Color(0xFF5E5470);
  static const outlineSoft = Color(0xFF7B6E93);

  static const textPrimary = Color(0xFFF4ECFF);
  static const textSecondary = Color(0xFFCDBAE3);
  static const textMuted = Color(0xFF9988B1);

  static const accentBlue = Color(0xFF4A86FF);
  static const accentViolet = Color(0xFF8E5BFF);
  static const accentPink = Color(0xFFD875FF);
  static const accentLavender = Color(0xFFE1BCFF);
  static const accentOrange = Color(0xFFDA7A31);

  static const star = Color(0xFF5B3C89);
  static const starMuted = Color(0xFF2A173F);

  static const formCardStart = Color(0xFF1F2024);
  static const formCardEnd = Color(0xFF28292F);
  static const formCardEndAlt = Color(0xFF292A30);

  static const pickerBg = Color(0xFF1A1526);
  static const sheetBg = Color(0xFF1A1523);
  static const switchTrack = Color(0xFF666874);
  static const iconMuted = Color(0xFFA7A8AF);

  static const previewOuter = Color(0xFF9C9EA8);
  static const previewInner = Color(0xFFCFD0D6);
  static const lockIcon = Color(0xFFE6DFF2);

  static const sheetTop = Color(0xFF5B30A2);
  static const sheetMid = Color(0xFF2A1F59);

  static const sysGreen = Color(0xFF35C759);
  static const sysBlue = Color(0xFF0A84FF);
  static const sysPurple = Color(0xFFAF52DE);
  static const sysOrange = Color(0xFFFF9F0A);

  static const screenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[background, background, backgroundMid, backgroundBottom],
    stops: <double>[0.0, 0.34, 0.74, 1.0],
  );

  static const accentGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[accentBlue, accentViolet, accentPink],
  );

  static const accentFillGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[Color(0xFF354E88), Color(0xFF4B3884), Color(0xFF7E439B)],
  );

  static const List<String> starnyxPresetColorHexes = <String>[
    '#AF2395',
    '#2360E9',
    '#DE7B30',
    '#1CB269',
  ];
}

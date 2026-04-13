import 'package:flutter/material.dart';

// Shared cosmic palette derived from the approved StarNyx UI mockups.
abstract final class AppColors {
  static const background = Color(0xFF05030A);
  static const backgroundMid = Color(0xFF1A0D2E);
  static const backgroundBottom = Color(0xFF6A38A5);

  static const surface = Color(0xFF26222E);
  static const surfaceElevated = Color(0xFF332E3D);
  static const outline = Color(0xFF5E5470);

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
}

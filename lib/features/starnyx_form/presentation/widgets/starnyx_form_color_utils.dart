import 'package:flutter/material.dart';
import 'package:starnyx/core/constants/core_constants.dart';

Color starnyxColorFromHex(String hex) {
  final normalized = normalizeStarnyxHex(hex).replaceFirst('#', '');
  final value = int.tryParse('FF$normalized', radix: 16);
  return value == null ? AppColors.primary : Color(value);
}

String normalizeStarnyxHex(String value) {
  final normalized = value.trim().toUpperCase();
  if (normalized.startsWith('#') && normalized.length == 7) {
    return normalized;
  }

  if (normalized.length == 6) {
    return '#$normalized';
  }

  return starnyxHexFromColor(AppColors.primary);
}

String starnyxHexFromColor(Color color) {
  final rgb = color.toARGB32() & 0x00FFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

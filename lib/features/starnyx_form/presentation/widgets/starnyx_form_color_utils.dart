import 'package:flutter/material.dart';

Color starnyxColorFromHex(String hex) {
  final normalized = normalizeStarnyxHex(hex).replaceFirst('#', '');
  return Color(int.parse('FF$normalized', radix: 16));
}

String normalizeStarnyxHex(String value) {
  final normalized = value.trim().toUpperCase();
  if (normalized.startsWith('#') && normalized.length == 7) {
    return normalized;
  }

  if (normalized.length == 6) {
    return '#$normalized';
  }

  return '#AF2395';
}

String starnyxHexFromColor(Color color) {
  final rgb = color.toARGB32() & 0x00FFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

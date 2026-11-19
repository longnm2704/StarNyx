import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const List<String> _locales = <String>['vi', 'en', 'ja'];

Map<String, String> _flatten(Map<String, dynamic> json, [String prefix = '']) {
  final result = <String, String>{};
  json.forEach((key, value) {
    final path = prefix.isEmpty ? key : '$prefix.$key';
    if (value is Map<String, dynamic>) {
      result.addAll(_flatten(value, path));
    } else {
      result[path] = value as String;
    }
  });
  return result;
}

Map<String, String> _load(String locale) => _flatten(
  jsonDecode(File('assets/translations/$locale.json').readAsStringSync())
      as Map<String, dynamic>,
);

void main() {
  final translations = <String, Map<String, String>>{
    for (final locale in _locales) locale: _load(locale),
  };

  test('vi, en and ja have identical key sets', () {
    final expected = translations['en']!.keys.toSet();
    for (final locale in _locales) {
      final keys = translations[locale]!.keys.toSet();
      expect(keys.difference(expected), isEmpty, reason: '$locale extra');
      expect(expected.difference(keys), isEmpty, reason: '$locale missing');
    }
  });

  test('placeholders match across locales and are renderable', () {
    // easy_localization fills `{}` (args) and `{name}` (namedArgs) only.
    final named = RegExp(r'\{([a-z]\w*)\}');
    for (final key in translations['en']!.keys) {
      final enValue = translations['en']![key]!;
      for (final locale in _locales) {
        final value = translations[locale]![key]!;
        expect(
          value,
          isNot(matches(RegExp(r'\{\d+\}'))),
          reason: '$locale.$key uses an indexed placeholder',
        );
        expect(
          '{}'.allMatches(value).length,
          '{}'.allMatches(enValue).length,
          reason: '$locale.$key positional placeholder count',
        );
        expect(
          named.allMatches(value).map((m) => m[1]).toSet(),
          named.allMatches(enValue).map((m) => m[1]).toSet(),
          reason: '$locale.$key named placeholders',
        );
      }
    }
  });

  test('copy has no exclamation marks or banned strings', () {
    final banned = RegExp(
      r'\bPRO\b|\bAI\b|クラウド|đám mây|OLED Sync|Home Habits|'
      r'Journal Notes|Overview List|Habit Tracker|LUMINESCENT TRACKER',
    );
    for (final locale in _locales) {
      translations[locale]!.forEach((key, value) {
        expect(value, isNot(contains('!')), reason: '$locale.$key');
        expect(value, isNot(contains('！')), reason: '$locale.$key');
        expect(
          value.toLowerCase().contains('cloud') || banned.hasMatch(value),
          isFalse,
          reason: '$locale.$key contains a banned string: $value',
        );
      });
    }
  });
}

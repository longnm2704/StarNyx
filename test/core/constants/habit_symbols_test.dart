import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:starnyx/core/constants/habit_symbols.dart';

void main() {
  test('star is the default and fallback key', () {
    expect(HabitSymbols.defaultKey, 'star');
    expect(HabitSymbols.icons['star'], isNotNull);
    expect(HabitSymbols.iconFor(null), HabitSymbols.icons['star']);
    expect(HabitSymbols.iconFor('unknown-key'), HabitSymbols.icons['star']);
    expect(HabitSymbols.iconFor(''), HabitSymbols.icons['star']);
  });

  test('every grouped key resolves to an icon', () {
    for (final group in HabitSymbols.groups) {
      for (final key in group.keys) {
        expect(
          HabitSymbols.icons[key],
          isNotNull,
          reason: 'missing icon for key "$key" in group "${group.label}"',
        );
      }
    }
  });

  test('groups cover the expected categories', () {
    expect(
      HabitSymbols.groups.map((group) => group.label),
      containsAll(<String>['Nature', 'Feelings', 'Energy', 'Sky', 'Daily life']),
    );
  });

  test('catalog has roughly twenty icons', () {
    expect(HabitSymbols.icons.length, greaterThanOrEqualTo(18));
    expect(HabitSymbols.icons.length, lessThanOrEqualTo(24));
  });

  test('every icon is a non-empty list of glyph elements', () {
    for (final entry in HabitSymbols.icons.entries) {
      expect(entry.value, isNotEmpty, reason: 'empty icon for "${entry.key}"');
      for (final element in entry.value) {
        expect(element, isA<List<dynamic>>());
        expect(element.length, 2);
      }
    }
  });

  test('star icon matches the Hugeicons stroke-rounded star', () {
    expect(
      HabitSymbols.icons['star'],
      HugeIconsStrokeRounded.strokeRoundedStar,
    );
  });
}

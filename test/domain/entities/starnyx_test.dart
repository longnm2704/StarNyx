import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/domain/entities/starnyx.dart';

// Locks the basic immutable contract of the StarNyx entity.
void main() {
  final startDate = DateTime(2026, 4, 1);
  final createdAt = DateTime(2026, 4, 1, 8);
  final updatedAt = DateTime(2026, 4, 2, 9);

  test('supports equality by value', () {
    const id = 'habit-1';

    final first = StarNyx(
      id: id,
      title: 'Hydrate',
      description: 'Drink enough water',
      color: '#123456',
      startDate: startDate,
      reminderEnabled: true,
      reminderTime: '09:00',
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    final second = StarNyx(
      id: id,
      title: 'Hydrate',
      description: 'Drink enough water',
      color: '#123456',
      startDate: startDate,
      reminderEnabled: true,
      reminderTime: '09:00',
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    expect(first, equals(second));
  });

  test('copyWith can clear nullable fields', () {
    final entity = StarNyx(
      id: 'habit-1',
      title: 'Hydrate',
      description: 'Drink enough water',
      color: '#123456',
      startDate: startDate,
      reminderEnabled: true,
      reminderTime: '09:00',
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    final copied = entity.copyWith(description: null, reminderTime: null);

    expect(copied.description, isNull);
    expect(copied.reminderTime, isNull);
  });
}

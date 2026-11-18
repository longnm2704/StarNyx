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
      icon: 'flame',
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
      icon: 'flame',
    );

    expect(first, equals(second));
  });

  test('icon defaults to star and is preserved by copyWith', () {
    final entity = StarNyx(
      id: 'habit-1',
      title: 'Hydrate',
      description: null,
      color: '#123456',
      startDate: startDate,
      reminderEnabled: false,
      reminderTime: null,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    expect(entity.icon, 'star');

    final copied = entity.copyWith(icon: 'clover');
    expect(copied.icon, 'clover');
    expect(entity.icon, 'star');
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
      icon: 'heart',
    );

    final copied = entity.copyWith(description: null, reminderTime: null);

    expect(copied.description, isNull);
    expect(copied.reminderTime, isNull);
    expect(copied.icon, 'heart');
  });
}

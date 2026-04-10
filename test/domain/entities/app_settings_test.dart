import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/domain/entities/app_settings.dart';

// Locks the nullable selection behavior of the app settings entity.
void main() {
  final updatedAt = DateTime(2026, 4, 10, 8, 30);

  test('reports selected StarNyx when an id exists', () {
    final settings = AppSettings(
      lastSelectedStarnyxId: 'habit-1',
      updatedAt: updatedAt,
    );

    expect(settings.hasSelectedStarnyx, isTrue);
  });

  test('copyWith can clear selected StarNyx id', () {
    final settings = AppSettings(
      lastSelectedStarnyxId: 'habit-1',
      updatedAt: updatedAt,
    );

    final copied = settings.copyWith(lastSelectedStarnyxId: null);

    expect(copied.lastSelectedStarnyxId, isNull);
    expect(copied.hasSelectedStarnyx, isFalse);
  });
}

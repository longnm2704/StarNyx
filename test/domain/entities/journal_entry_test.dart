import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/domain/entities/journal_entry.dart';

void main() {
  test('JournalEntry supports value equality', () {
    final entry1 = JournalEntry(
      id: 1,
      starnyxId: 's-1',
      date: DateTime(2026, 4, 16),
      content: 'Note content',
      createdAt: DateTime(2026, 4, 16, 10, 0),
    );
    final entry2 = JournalEntry(
      id: 1,
      starnyxId: 's-1',
      date: DateTime(2026, 4, 16),
      content: 'Note content',
      createdAt: DateTime(2026, 4, 16, 10, 0),
    );

    expect(entry1, equals(entry2));
  });

  test('JournalEntry copyWith creates a new instance with updated fields', () {
    final original = JournalEntry(
      id: 1,
      starnyxId: 's-1',
      date: DateTime(2026, 4, 16),
      content: 'Original',
      createdAt: DateTime(2026, 4, 16, 10, 0),
    );
    final updated = original.copyWith(content: 'Updated');

    expect(updated.content, 'Updated');
    expect(updated.starnyxId, 's-1');
    expect(updated.id, 1);
  });
}

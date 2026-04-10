import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/domain/entities/journal_entry.dart';

// Locks the immutable contract of daily journal entries.
void main() {
  test('copyWith updates journal content by value', () {
    final entry = JournalEntry(
      starnyxId: 'habit-1',
      date: DateTime(2026, 4, 10),
      content: 'Old note',
    );

    final copied = entry.copyWith(content: 'New note');

    expect(copied.starnyxId, 'habit-1');
    expect(copied.date, DateTime(2026, 4, 10));
    expect(copied.content, 'New note');
  });
}

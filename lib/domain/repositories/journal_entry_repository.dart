import 'package:starnyx/domain/entities/journal_entry.dart';

// Contract for reading and writing daily journal notes.
abstract interface class JournalEntryRepository {
  // Journal screens need the full list of notes for one StarNyx.
  Future<List<JournalEntry>> getJournalEntriesForStarnyx(String starnyxId);

  // Watchers keep note history reactive after save and delete actions.
  Stream<List<JournalEntry>> watchJournalEntriesForStarnyx(String starnyxId);

  // Save-note flows need to load the entry for a specific date.
  Future<JournalEntry?> getJournalEntryByDate({
    required String starnyxId,
    required DateTime date,
  });

  // Save abstracts both create and update behavior for one note.
  Future<void> saveJournalEntry(JournalEntry entry);

  // Targeted delete removes a note for one specific day.
  Future<void> deleteJournalEntryByDate({
    required String starnyxId,
    required DateTime date,
  });

  // Bulk delete helps imports and StarNyx deletion clean up related data.
  Future<void> deleteJournalEntriesForStarnyx(String starnyxId);
}

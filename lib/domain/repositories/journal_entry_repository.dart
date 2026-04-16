import 'package:starnyx/domain/entities/journal_entry.dart';

// Contract for reading and writing daily journal notes.
abstract interface class JournalEntryRepository {
  // Journal screens need the full list of notes for one StarNyx.
  Future<List<JournalEntry>> getJournalEntriesForStarnyx(String starnyxId);

  // Watchers keep note history reactive after save and delete actions.
  Stream<List<JournalEntry>> watchJournalEntriesForStarnyx(String starnyxId);

  // Fetching entries for a specific day.
  Future<List<JournalEntry>> getJournalEntriesForDate({
    required String starnyxId,
    required DateTime date,
  });

  // Save abstracts both create behavior for one note.
  Future<void> saveJournalEntry(JournalEntry entry);

  // Targeted delete removes a note by its ID.
  Future<void> deleteJournalEntryById(int id);

  // Bulk delete helps imports and StarNyx deletion clean up related data.
  Future<void> deleteJournalEntriesForStarnyx(String starnyxId);
}

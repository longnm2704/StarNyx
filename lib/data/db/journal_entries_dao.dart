part of 'app_database.dart';

// Data access helpers for daily journal entries.
@DriftAccessor(tables: <Type>[JournalEntries])
class JournalEntriesDao extends DatabaseAccessor<AppDatabase>
    with _$JournalEntriesDaoMixin {
  JournalEntriesDao(super.db);

  // Journal history is easier to render with the newest entry first.
  Future<List<JournalEntry>> getJournalEntriesForStarnyx(String starnyxId) {
    return (select(journalEntries)
          ..where((table) => table.starnyxId.equals(starnyxId))
          ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]))
        .get();
  }

  // Watchers keep future journal screens reactive without extra reload logic.
  Stream<List<JournalEntry>> watchJournalEntriesForStarnyx(String starnyxId) {
    return (select(journalEntries)
          ..where((table) => table.starnyxId.equals(starnyxId))
          ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]))
        .watch();
  }

  // Fetching entries for a specific day.
  Future<List<JournalEntry>> getJournalEntriesForDate({
    required String starnyxId,
    required String date,
  }) {
    return (select(journalEntries)..where(
          (table) =>
              table.starnyxId.equals(starnyxId) & table.date.equals(date),
        )..orderBy([(table) => OrderingTerm.desc(table.createdAt)]))
        .get();
  }

  // Insert a new journal entry.
  Future<int> insertJournalEntry(JournalEntriesCompanion companion) {
    return into(journalEntries).insert(companion);
  }

  // Delete a specific entry by its primary key ID.
  Future<int> deleteJournalEntryById(int id) {
    return (delete(journalEntries)..where((table) => table.id.equals(id))).go();
  }

  // Bulk cleanup is useful for imports and StarNyx deletion.
  Future<int> deleteJournalEntriesForStarnyx(String starnyxId) {
    return (delete(
      journalEntries,
    )..where((table) => table.starnyxId.equals(starnyxId))).go();
  }
}

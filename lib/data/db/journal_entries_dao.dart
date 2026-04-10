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
          ..orderBy([(table) => OrderingTerm.desc(table.date)]))
        .get();
  }

  // Watchers keep future journal screens reactive without extra reload logic.
  Stream<List<JournalEntry>> watchJournalEntriesForStarnyx(String starnyxId) {
    return (select(journalEntries)
          ..where((table) => table.starnyxId.equals(starnyxId))
          ..orderBy([(table) => OrderingTerm.desc(table.date)]))
        .watch();
  }

  // Save-note flows often need to inspect one journal entry for one date.
  Future<JournalEntry?> getJournalEntry({
    required String starnyxId,
    required String date,
  }) {
    return (select(journalEntries)..where(
          (table) =>
              table.starnyxId.equals(starnyxId) & table.date.equals(date),
        ))
        .getSingleOrNull();
  }

  // Composite key upsert keeps one journal entry per StarNyx per date.
  Future<void> upsertJournalEntry(JournalEntriesCompanion companion) {
    return into(journalEntries).insertOnConflictUpdate(companion);
  }

  // Targeted deletes are used when a single entry is cleared by date.
  Future<int> deleteJournalEntry({
    required String starnyxId,
    required String date,
  }) {
    return (delete(journalEntries)..where(
          (table) =>
              table.starnyxId.equals(starnyxId) & table.date.equals(date),
        ))
        .go();
  }

  // Bulk cleanup is useful for imports and StarNyx deletion.
  Future<int> deleteJournalEntriesForStarnyx(String starnyxId) {
    return (delete(
      journalEntries,
    )..where((table) => table.starnyxId.equals(starnyxId))).go();
  }
}

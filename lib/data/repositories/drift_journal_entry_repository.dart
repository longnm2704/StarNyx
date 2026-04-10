import 'package:drift/drift.dart';
import 'package:starnyx/data/db/app_database.dart';
import 'package:starnyx/domain/entities/journal_entry.dart' as domain;
import 'package:starnyx/data/repositories/drift_repository_mappers.dart';
import 'package:starnyx/domain/repositories/journal_entry_repository.dart';

// Drift-backed implementation of the journal entry repository contract.
class DriftJournalEntryRepository implements JournalEntryRepository {
  const DriftJournalEntryRepository(this._database);

  final AppDatabase _database;

  @override
  Future<List<domain.JournalEntry>> getJournalEntriesForStarnyx(
    String starnyxId,
  ) async {
    final rows = await _database.journalEntriesDao.getJournalEntriesForStarnyx(
      starnyxId,
    );
    return rows.map((row) => row.toDomain()).toList(growable: false);
  }

  @override
  Stream<List<domain.JournalEntry>> watchJournalEntriesForStarnyx(
    String starnyxId,
  ) {
    return _database.journalEntriesDao
        .watchJournalEntriesForStarnyx(starnyxId)
        .map(
          (rows) => rows.map((row) => row.toDomain()).toList(growable: false),
        );
  }

  @override
  Future<domain.JournalEntry?> getJournalEntryByDate({
    required String starnyxId,
    required DateTime date,
  }) async {
    final row = await _database.journalEntriesDao.getJournalEntry(
      starnyxId: starnyxId,
      date: dateKeyFromDateTime(date),
    );
    return row?.toDomain();
  }

  @override
  Future<void> saveJournalEntry(domain.JournalEntry entry) {
    return _database.journalEntriesDao.upsertJournalEntry(
      JournalEntriesCompanion(
        starnyxId: Value(entry.starnyxId),
        date: Value(dateKeyFromDateTime(entry.date)),
        content: Value(entry.content),
      ),
    );
  }

  @override
  Future<void> deleteJournalEntryByDate({
    required String starnyxId,
    required DateTime date,
  }) async {
    await _database.journalEntriesDao.deleteJournalEntry(
      starnyxId: starnyxId,
      date: dateKeyFromDateTime(date),
    );
  }

  @override
  Future<void> deleteJournalEntriesForStarnyx(String starnyxId) async {
    await _database.journalEntriesDao.deleteJournalEntriesForStarnyx(starnyxId);
  }
}

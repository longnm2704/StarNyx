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
  Future<List<domain.JournalEntry>> getJournalEntriesForDate({
    required String starnyxId,
    required DateTime date,
  }) async {
    final rows = await _database.journalEntriesDao.getJournalEntriesForDate(
      starnyxId: starnyxId,
      date: dateKeyFromDateTime(date),
    );
    return rows.map((row) => row.toDomain()).toList(growable: false);
  }

  @override
  Future<void> saveJournalEntry(domain.JournalEntry entry) {
    return _database.journalEntriesDao.insertJournalEntry(
      JournalEntriesCompanion.insert(
        starnyxId: entry.starnyxId,
        date: dateKeyFromDateTime(entry.date),
        content: entry.content,
        createdAt: Value(entry.createdAt),
      ),
    );
  }

  @override
  Future<void> deleteJournalEntryById(int id) async {
    await _database.journalEntriesDao.deleteJournalEntryById(id);
  }

  @override
  Future<void> deleteJournalEntriesForStarnyx(String starnyxId) async {
    await _database.journalEntriesDao.deleteJournalEntriesForStarnyx(starnyxId);
  }
}

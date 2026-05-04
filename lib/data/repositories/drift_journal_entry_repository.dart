import 'package:drift/drift.dart';
import 'package:starnyx/data/db/app_database.dart';
import 'package:starnyx/core/services/app_log_service.dart';
import 'package:starnyx/domain/entities/journal_entry.dart' as domain;
import 'package:starnyx/data/repositories/drift_repository_mappers.dart';
import 'package:starnyx/domain/repositories/journal_entry_repository.dart';

// Drift-backed implementation of the journal entry repository contract.
class DriftJournalEntryRepository implements JournalEntryRepository {
  const DriftJournalEntryRepository(
    this._database, {
    AppLogService logger = const NoOpAppLogService(),
  }) : _logger = logger;

  final AppDatabase _database;
  final AppLogService _logger;

  @override
  Future<List<domain.JournalEntry>> getJournalEntriesForStarnyx(
    String starnyxId,
  ) async {
    _logger.debug(
      'DriftJournalEntryRepository',
      'get all begin starnyxId=$starnyxId',
    );
    final rows = await _database.journalEntriesDao.getJournalEntriesForStarnyx(
      starnyxId,
    );
    final entries = rows.map((row) => row.toDomain()).toList(growable: false);
    _logger.debug(
      'DriftJournalEntryRepository',
      'get all success starnyxId=$starnyxId count=${entries.length}',
    );
    return entries;
  }

  @override
  Stream<List<domain.JournalEntry>> watchJournalEntriesForStarnyx(
    String starnyxId,
  ) {
    _logger.debug(
      'DriftJournalEntryRepository',
      'watch begin starnyxId=$starnyxId',
    );
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
    final dateKey = dateKeyFromDateTime(date);
    _logger.debug(
      'DriftJournalEntryRepository',
      'get by date begin starnyxId=$starnyxId date=$dateKey',
    );
    final rows = await _database.journalEntriesDao.getJournalEntriesForDate(
      starnyxId: starnyxId,
      date: dateKey,
    );
    final entries = rows.map((row) => row.toDomain()).toList(growable: false);
    _logger.debug(
      'DriftJournalEntryRepository',
      'get by date success starnyxId=$starnyxId date=$dateKey count=${entries.length}',
    );
    return entries;
  }

  @override
  Future<void> saveJournalEntry(domain.JournalEntry entry) async {
    final dateKey = dateKeyFromDateTime(entry.date);
    _logger.debug(
      'DriftJournalEntryRepository',
      'insert begin starnyxId=${entry.starnyxId} date=$dateKey '
          'contentLength=${entry.content.length}',
    );
    await _database.journalEntriesDao.insertJournalEntry(
      JournalEntriesCompanion.insert(
        starnyxId: entry.starnyxId,
        date: dateKey,
        content: entry.content,
        createdAt: Value(entry.createdAt),
      ),
    );
    _logger.debug(
      'DriftJournalEntryRepository',
      'insert success starnyxId=${entry.starnyxId} date=$dateKey',
    );
  }

  @override
  Future<void> deleteJournalEntryById(int id) async {
    _logger.debug('DriftJournalEntryRepository', 'delete begin id=$id');
    await _database.journalEntriesDao.deleteJournalEntryById(id);
    _logger.debug('DriftJournalEntryRepository', 'delete success id=$id');
  }

  @override
  Future<void> deleteJournalEntriesForStarnyx(String starnyxId) async {
    _logger.debug(
      'DriftJournalEntryRepository',
      'delete all begin starnyxId=$starnyxId',
    );
    await _database.journalEntriesDao.deleteJournalEntriesForStarnyx(starnyxId);
    _logger.debug(
      'DriftJournalEntryRepository',
      'delete all success starnyxId=$starnyxId',
    );
  }
}

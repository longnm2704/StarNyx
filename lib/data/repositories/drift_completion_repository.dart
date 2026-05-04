import 'package:drift/drift.dart';
import 'package:starnyx/data/db/app_database.dart';
import 'package:starnyx/core/services/app_log_service.dart';
import 'package:starnyx/domain/entities/completion.dart' as domain;
import 'package:starnyx/domain/repositories/completion_repository.dart';
import 'package:starnyx/data/repositories/drift_repository_mappers.dart';

// Drift-backed implementation of the completion repository contract.
class DriftCompletionRepository implements CompletionRepository {
  const DriftCompletionRepository(
    this._database, {
    AppLogService logger = const NoOpAppLogService(),
  }) : _logger = logger;

  final AppDatabase _database;
  final AppLogService _logger;

  @override
  Future<List<domain.Completion>> getCompletionsForStarnyx(
    String starnyxId,
  ) async {
    _logger.debug(
      'DriftCompletionRepository',
      'get all begin starnyxId=$starnyxId',
    );
    final rows = await _database.completionsDao.getCompletionsForStarnyx(
      starnyxId,
    );
    final completions = rows
        .map((row) => row.toDomain())
        .toList(growable: false);
    _logger.debug(
      'DriftCompletionRepository',
      'get all success starnyxId=$starnyxId count=${completions.length}',
    );
    return completions;
  }

  @override
  Stream<List<domain.Completion>> watchCompletionsForStarnyx(String starnyxId) {
    _logger.debug(
      'DriftCompletionRepository',
      'watch begin starnyxId=$starnyxId',
    );
    return _database.completionsDao
        .watchCompletionsForStarnyx(starnyxId)
        .map(
          (rows) => rows.map((row) => row.toDomain()).toList(growable: false),
        );
  }

  @override
  Future<domain.Completion?> getCompletionByDate({
    required String starnyxId,
    required DateTime date,
  }) async {
    final dateKey = dateKeyFromDateTime(date);
    _logger.debug(
      'DriftCompletionRepository',
      'get by date begin starnyxId=$starnyxId date=$dateKey',
    );
    final row = await _database.completionsDao.getCompletion(
      starnyxId: starnyxId,
      date: dateKey,
    );
    final completion = row?.toDomain();
    _logger.debug(
      'DriftCompletionRepository',
      'get by date success starnyxId=$starnyxId date=$dateKey found=${completion != null}',
    );
    return completion;
  }

  @override
  Future<void> saveCompletion(domain.Completion completion) async {
    final dateKey = dateKeyFromDateTime(completion.date);
    _logger.debug(
      'DriftCompletionRepository',
      'upsert begin starnyxId=${completion.starnyxId} date=$dateKey '
          'completed=${completion.completed}',
    );
    await _database.completionsDao.upsertCompletion(
      CompletionsCompanion(
        starnyxId: Value(completion.starnyxId),
        date: Value(dateKey),
        completed: Value(completion.completed),
      ),
    );
    _logger.debug(
      'DriftCompletionRepository',
      'upsert success starnyxId=${completion.starnyxId} date=$dateKey',
    );
  }

  @override
  Future<void> deleteCompletionByDate({
    required String starnyxId,
    required DateTime date,
  }) async {
    final dateKey = dateKeyFromDateTime(date);
    _logger.debug(
      'DriftCompletionRepository',
      'delete by date begin starnyxId=$starnyxId date=$dateKey',
    );
    await _database.completionsDao.deleteCompletion(
      starnyxId: starnyxId,
      date: dateKey,
    );
    _logger.debug(
      'DriftCompletionRepository',
      'delete by date success starnyxId=$starnyxId date=$dateKey',
    );
  }

  @override
  Future<void> deleteCompletionsForStarnyx(String starnyxId) async {
    _logger.debug(
      'DriftCompletionRepository',
      'delete all begin starnyxId=$starnyxId',
    );
    await _database.completionsDao.deleteCompletionsForStarnyx(starnyxId);
    _logger.debug(
      'DriftCompletionRepository',
      'delete all success starnyxId=$starnyxId',
    );
  }
}

import 'package:drift/drift.dart';
import 'package:starnyx/data/db/app_database.dart';
import 'package:starnyx/domain/entities/completion.dart' as domain;
import 'package:starnyx/domain/repositories/completion_repository.dart';
import 'package:starnyx/data/repositories/drift_repository_mappers.dart';

// Drift-backed implementation of the completion repository contract.
class DriftCompletionRepository implements CompletionRepository {
  const DriftCompletionRepository(this._database);

  final AppDatabase _database;

  @override
  Future<List<domain.Completion>> getCompletionsForStarnyx(
    String starnyxId,
  ) async {
    final rows = await _database.completionsDao.getCompletionsForStarnyx(
      starnyxId,
    );
    return rows.map((row) => row.toDomain()).toList(growable: false);
  }

  @override
  Stream<List<domain.Completion>> watchCompletionsForStarnyx(String starnyxId) {
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
    final row = await _database.completionsDao.getCompletion(
      starnyxId: starnyxId,
      date: dateKeyFromDateTime(date),
    );
    return row?.toDomain();
  }

  @override
  Future<void> saveCompletion(domain.Completion completion) {
    return _database.completionsDao.upsertCompletion(
      CompletionsCompanion(
        starnyxId: Value(completion.starnyxId),
        date: Value(dateKeyFromDateTime(completion.date)),
        completed: Value(completion.completed),
      ),
    );
  }

  @override
  Future<void> deleteCompletionByDate({
    required String starnyxId,
    required DateTime date,
  }) async {
    await _database.completionsDao.deleteCompletion(
      starnyxId: starnyxId,
      date: dateKeyFromDateTime(date),
    );
  }

  @override
  Future<void> deleteCompletionsForStarnyx(String starnyxId) async {
    await _database.completionsDao.deleteCompletionsForStarnyx(starnyxId);
  }
}

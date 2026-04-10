import 'package:drift/drift.dart';
import 'package:starnyx/data/db/app_database.dart';
import 'package:starnyx/domain/entities/starnyx.dart' as domain;
import 'package:starnyx/domain/repositories/starnyx_repository.dart';
import 'package:starnyx/data/repositories/drift_repository_mappers.dart';

// Drift-backed implementation of the StarNyx repository contract.
class DriftStarNyxRepository implements StarNyxRepository {
  const DriftStarNyxRepository(this._database);

  final AppDatabase _database;

  @override
  Future<List<domain.StarNyx>> getAllStarnyxs() async {
    final rows = await _database.starnyxsDao.getAllStarnyxs();
    return rows.map((row) => row.toDomain()).toList(growable: false);
  }

  @override
  Stream<List<domain.StarNyx>> watchAllStarnyxs() {
    return _database.starnyxsDao.watchAllStarnyxs().map(
      (rows) => rows.map((row) => row.toDomain()).toList(growable: false),
    );
  }

  @override
  Future<domain.StarNyx?> getStarnyxById(String id) async {
    final row = await _database.starnyxsDao.getStarnyxById(id);
    return row?.toDomain();
  }

  @override
  Future<void> saveStarnyx(domain.StarNyx starnyx) {
    return _database.starnyxsDao.upsertStarnyx(
      StarNyxsCompanion(
        id: Value(starnyx.id),
        title: Value(starnyx.title),
        description: Value(starnyx.description),
        color: Value(starnyx.color),
        startDate: Value(dateKeyFromDateTime(starnyx.startDate)),
        reminderEnabled: Value(starnyx.reminderEnabled),
        reminderTime: Value(starnyx.reminderTime),
        createdAt: Value(starnyx.createdAt),
        updatedAt: Value(starnyx.updatedAt),
      ),
    );
  }

  @override
  Future<void> deleteStarnyxById(String id) async {
    await _database.starnyxsDao.deleteStarnyxById(id);
  }
}

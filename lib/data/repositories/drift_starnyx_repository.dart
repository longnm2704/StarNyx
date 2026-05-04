import 'package:drift/drift.dart';
import 'package:starnyx/data/db/app_database.dart';
import 'package:starnyx/core/services/app_log_service.dart';
import 'package:starnyx/domain/entities/starnyx.dart' as domain;
import 'package:starnyx/domain/repositories/starnyx_repository.dart';
import 'package:starnyx/data/repositories/drift_repository_mappers.dart';

// Drift-backed implementation of the StarNyx repository contract.
class DriftStarNyxRepository implements StarNyxRepository {
  const DriftStarNyxRepository(
    this._database, {
    AppLogService logger = const NoOpAppLogService(),
  }) : _logger = logger;

  final AppDatabase _database;
  final AppLogService _logger;

  @override
  Future<List<domain.StarNyx>> getAllStarnyxs() async {
    _logger.debug('DriftStarNyxRepository', 'get all begin');
    final rows = await _database.starnyxsDao.getAllStarnyxs();
    final starnyxs = rows.map((row) => row.toDomain()).toList(growable: false);
    _logger.debug(
      'DriftStarNyxRepository',
      'get all success count=${starnyxs.length}',
    );
    return starnyxs;
  }

  @override
  Stream<List<domain.StarNyx>> watchAllStarnyxs() {
    _logger.debug('DriftStarNyxRepository', 'watch all begin');
    return _database.starnyxsDao.watchAllStarnyxs().map(
      (rows) => rows.map((row) => row.toDomain()).toList(growable: false),
    );
  }

  @override
  Future<domain.StarNyx?> getStarnyxById(String id) async {
    _logger.debug('DriftStarNyxRepository', 'get by id begin id=$id');
    final row = await _database.starnyxsDao.getStarnyxById(id);
    final starnyx = row?.toDomain();
    _logger.debug(
      'DriftStarNyxRepository',
      'get by id success id=$id found=${starnyx != null}',
    );
    return starnyx;
  }

  @override
  Future<void> saveStarnyx(domain.StarNyx starnyx) async {
    final startDateKey = dateKeyFromDateTime(starnyx.startDate);
    _logger.debug(
      'DriftStarNyxRepository',
      'upsert begin id=${starnyx.id} title="${starnyx.title}" '
          'startDateKey=$startDateKey updatedAt=${starnyx.updatedAt}',
    );

    try {
      await _database.starnyxsDao.upsertStarnyx(
        StarNyxsCompanion(
          id: Value(starnyx.id),
          title: Value(starnyx.title),
          description: Value(starnyx.description),
          color: Value(starnyx.color),
          startDate: Value(startDateKey),
          reminderEnabled: Value(starnyx.reminderEnabled),
          reminderTime: Value(starnyx.reminderTime),
          createdAt: Value(starnyx.createdAt),
          updatedAt: Value(starnyx.updatedAt),
        ),
      );
      _logger.debug(
        'DriftStarNyxRepository',
        'upsert success id=${starnyx.id}',
      );
    } catch (error, stackTrace) {
      _logger.error(
        'DriftStarNyxRepository',
        'upsert failed id=${starnyx.id}',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteStarnyxById(String id) async {
    _logger.debug('DriftStarNyxRepository', 'delete begin id=$id');
    await _database.starnyxsDao.deleteStarnyxById(id);
    _logger.debug('DriftStarNyxRepository', 'delete success id=$id');
  }
}

import 'package:drift/drift.dart';
import 'package:starnyx/data/db/app_database.dart';
import 'package:starnyx/core/services/app_log_service.dart';
import 'package:starnyx/domain/entities/app_settings.dart' as domain;
import 'package:starnyx/data/repositories/drift_repository_mappers.dart';
import 'package:starnyx/domain/repositories/app_settings_repository.dart';

// Drift-backed implementation of the app settings repository contract.
class DriftAppSettingsRepository implements AppSettingsRepository {
  const DriftAppSettingsRepository(
    this._database, {
    AppLogService logger = const NoOpAppLogService(),
  }) : _logger = logger;

  final AppDatabase _database;
  final AppLogService _logger;

  @override
  Future<domain.AppSettings?> getAppSettings() async {
    _logger.debug('DriftAppSettingsRepository', 'get begin');
    final row = await _database.appSettingsDao.getAppSettings();
    final settings = row?.toDomain();
    _logger.debug(
      'DriftAppSettingsRepository',
      'get success selectedId=${settings?.lastSelectedStarnyxId}',
    );
    return settings;
  }

  @override
  Stream<domain.AppSettings?> watchAppSettings() {
    _logger.debug('DriftAppSettingsRepository', 'watch begin');
    return _database.appSettingsDao.watchAppSettings().map(
      (row) => row?.toDomain(),
    );
  }

  @override
  Future<void> saveAppSettings(domain.AppSettings settings) async {
    _logger.debug(
      'DriftAppSettingsRepository',
      'upsert begin selectedId=${settings.lastSelectedStarnyxId}',
    );
    await _database.appSettingsDao.upsertAppSettings(
      AppSettingsCompanion(
        id: const Value(1),
        lastSelectedStarnyxId: Value(settings.lastSelectedStarnyxId),
        updatedAt: Value(settings.updatedAt),
      ),
    );
    _logger.debug('DriftAppSettingsRepository', 'upsert success');
  }
}

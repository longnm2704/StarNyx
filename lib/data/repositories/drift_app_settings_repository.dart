import 'package:drift/drift.dart';
import 'package:starnyx/data/db/app_database.dart';
import 'package:starnyx/domain/entities/app_settings.dart' as domain;
import 'package:starnyx/data/repositories/drift_repository_mappers.dart';
import 'package:starnyx/domain/repositories/app_settings_repository.dart';

// Drift-backed implementation of the app settings repository contract.
class DriftAppSettingsRepository implements AppSettingsRepository {
  const DriftAppSettingsRepository(this._database);

  final AppDatabase _database;

  @override
  Future<domain.AppSettings?> getAppSettings() async {
    final row = await _database.appSettingsDao.getAppSettings();
    return row?.toDomain();
  }

  @override
  Stream<domain.AppSettings?> watchAppSettings() {
    return _database.appSettingsDao.watchAppSettings().map(
      (row) => row?.toDomain(),
    );
  }

  @override
  Future<void> saveAppSettings(domain.AppSettings settings) {
    return _database.appSettingsDao.upsertAppSettings(
      AppSettingsCompanion(
        id: const Value(1),
        lastSelectedStarnyxId: Value(settings.lastSelectedStarnyxId),
        updatedAt: Value(settings.updatedAt),
      ),
    );
  }
}

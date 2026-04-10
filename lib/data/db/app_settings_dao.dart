part of 'app_database.dart';

// Data access helpers for the single app-wide settings row.
@DriftAccessor(tables: <Type>[AppSettings])
class AppSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$AppSettingsDaoMixin {
  AppSettingsDao(super.db);

  // MVP settings live in a single row with id = 1.
  Future<AppSetting?> getAppSettings() {
    return (select(
      appSettings,
    )..where((table) => table.id.equals(1))).getSingleOrNull();
  }

  // Watchers keep selected StarNyx state in sync across screens.
  Stream<AppSetting?> watchAppSettings() {
    return (select(
      appSettings,
    )..where((table) => table.id.equals(1))).watchSingleOrNull();
  }

  // Upsert keeps the single-row settings table simple to maintain.
  Future<void> upsertAppSettings(AppSettingsCompanion companion) {
    return into(appSettings).insertOnConflictUpdate(companion);
  }
}

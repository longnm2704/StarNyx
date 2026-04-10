import 'package:starnyx/domain/entities/app_settings.dart';

// Contract for app-wide settings that are independent from one feature screen.
abstract interface class AppSettingsRepository {
  // Startup and restore flows need the latest settings snapshot on demand.
  Future<AppSettings?> getAppSettings();

  // Watchers keep selected StarNyx state synchronized across screens.
  Stream<AppSettings?> watchAppSettings();

  // Save abstracts both first-write and later updates of the single settings row.
  Future<void> saveAppSettings(AppSettings settings);
}

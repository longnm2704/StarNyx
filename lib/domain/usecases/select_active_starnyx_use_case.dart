import 'package:starnyx/core/services/app_log_service.dart';
import 'package:starnyx/domain/entities/app_settings.dart';
import 'package:starnyx/domain/repositories/starnyx_repository.dart';
import 'package:starnyx/domain/repositories/app_settings_repository.dart';

// Persists which StarNyx should be restored as the active one.
class SelectActiveStarNyxUseCase {
  const SelectActiveStarNyxUseCase(
    this._starnyxRepository,
    this._appSettingsRepository, {
    AppLogService logger = const NoOpAppLogService(),
  }) : _logger = logger;

  final StarNyxRepository _starnyxRepository;
  final AppSettingsRepository _appSettingsRepository;
  final AppLogService _logger;

  Future<void> call(String id, {DateTime? now}) async {
    _logger.debug('SelectActiveStarNyxUseCase', 'select begin id=$id');
    final starnyx = await _starnyxRepository.getStarnyxById(id);
    if (starnyx == null) {
      throw StateError('StarNyx with id $id was not found.');
    }

    await _appSettingsRepository.saveAppSettings(
      AppSettings(lastSelectedStarnyxId: id, updatedAt: now ?? DateTime.now()),
    );
    _logger.debug('SelectActiveStarNyxUseCase', 'select success id=$id');
  }
}

import 'package:starnyx/core/services/app_log_service.dart';
import 'package:starnyx/domain/entities/app_settings.dart';
import 'package:starnyx/domain/repositories/starnyx_repository.dart';
import 'package:starnyx/domain/repositories/app_settings_repository.dart';

// Deletes a StarNyx and repairs active selection when needed.
class DeleteStarNyxUseCase {
  const DeleteStarNyxUseCase(
    this._starnyxRepository,
    this._appSettingsRepository, {
    AppLogService logger = const NoOpAppLogService(),
  }) : _logger = logger;

  final StarNyxRepository _starnyxRepository;
  final AppSettingsRepository _appSettingsRepository;
  final AppLogService _logger;

  Future<void> call(String id, {DateTime? now}) async {
    _logger.debug('DeleteStarNyxUseCase', 'delete begin id=$id');
    await _starnyxRepository.deleteStarnyxById(id);

    final settings = await _appSettingsRepository.getAppSettings();
    if (settings?.lastSelectedStarnyxId != id) {
      _logger.debug('DeleteStarNyxUseCase', 'delete success id=$id');
      return;
    }

    final remainingStarnyxs = await _starnyxRepository.getAllStarnyxs();
    final fallbackId = remainingStarnyxs.isEmpty
        ? null
        : remainingStarnyxs.first.id;

    await _appSettingsRepository.saveAppSettings(
      AppSettings(
        lastSelectedStarnyxId: fallbackId,
        updatedAt: now ?? DateTime.now(),
      ),
    );
    _logger.debug(
      'DeleteStarNyxUseCase',
      'delete success id=$id fallbackId=$fallbackId',
    );
  }
}

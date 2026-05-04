import 'package:starnyx/core/services/app_log_service.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/entities/app_settings.dart';
import 'package:starnyx/domain/repositories/starnyx_repository.dart';
import 'package:starnyx/domain/repositories/app_settings_repository.dart';

// Resolves the active StarNyx and repairs stale selection state when needed.
class LoadActiveStarNyxUseCase {
  const LoadActiveStarNyxUseCase(
    this._starnyxRepository,
    this._appSettingsRepository, {
    AppLogService logger = const NoOpAppLogService(),
  }) : _logger = logger;

  final StarNyxRepository _starnyxRepository;
  final AppSettingsRepository _appSettingsRepository;
  final AppLogService _logger;

  Future<StarNyx?> call({DateTime? now}) async {
    final settings = await _appSettingsRepository.getAppSettings();
    final selectedId = settings?.lastSelectedStarnyxId;
    _logger.debug(
      'LoadActiveStarNyxUseCase',
      'load begin selectedId=$selectedId',
    );

    if (selectedId != null) {
      final selected = await _starnyxRepository.getStarnyxById(selectedId);
      if (selected != null) {
        _logger.debug(
          'LoadActiveStarNyxUseCase',
          'load selected id=${selected.id}',
        );
        return selected;
      }
    }

    final starnyxs = await _starnyxRepository.getAllStarnyxs();
    if (starnyxs.isEmpty) {
      if (selectedId != null) {
        await _appSettingsRepository.saveAppSettings(
          AppSettings(
            lastSelectedStarnyxId: null,
            updatedAt: now ?? DateTime.now(),
          ),
        );
      }
      _logger.debug('LoadActiveStarNyxUseCase', 'load empty');
      return null;
    }

    final fallback = starnyxs.first;
    if (selectedId != fallback.id) {
      await _appSettingsRepository.saveAppSettings(
        AppSettings(
          lastSelectedStarnyxId: fallback.id,
          updatedAt: now ?? DateTime.now(),
        ),
      );
    }

    _logger.debug(
      'LoadActiveStarNyxUseCase',
      'load fallback id=${fallback.id}',
    );
    return fallback;
  }
}

import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/entities/app_settings.dart';
import 'package:starnyx/domain/repositories/starnyx_repository.dart';
import 'package:starnyx/domain/repositories/app_settings_repository.dart';

// Resolves the active StarNyx and repairs stale selection state when needed.
class LoadActiveStarNyxUseCase {
  const LoadActiveStarNyxUseCase(
    this._starnyxRepository,
    this._appSettingsRepository,
  );

  final StarNyxRepository _starnyxRepository;
  final AppSettingsRepository _appSettingsRepository;

  Future<StarNyx?> call({DateTime? now}) async {
    final settings = await _appSettingsRepository.getAppSettings();
    final selectedId = settings?.lastSelectedStarnyxId;

    if (selectedId != null) {
      final selected = await _starnyxRepository.getStarnyxById(selectedId);
      if (selected != null) {
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

    return fallback;
  }
}

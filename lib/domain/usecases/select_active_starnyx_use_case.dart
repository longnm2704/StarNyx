import 'package:starnyx/domain/entities/app_settings.dart';
import 'package:starnyx/domain/repositories/starnyx_repository.dart';
import 'package:starnyx/domain/repositories/app_settings_repository.dart';

// Persists which StarNyx should be restored as the active one.
class SelectActiveStarNyxUseCase {
  const SelectActiveStarNyxUseCase(
    this._starnyxRepository,
    this._appSettingsRepository,
  );

  final StarNyxRepository _starnyxRepository;
  final AppSettingsRepository _appSettingsRepository;

  Future<void> call(String id, {DateTime? now}) async {
    final starnyx = await _starnyxRepository.getStarnyxById(id);
    if (starnyx == null) {
      throw StateError('StarNyx with id $id was not found.');
    }

    await _appSettingsRepository.saveAppSettings(
      AppSettings(lastSelectedStarnyxId: id, updatedAt: now ?? DateTime.now()),
    );
  }
}

import 'package:starnyx/core/services/core_services.dart';
import 'package:starnyx/domain/usecases/sync_notifications_use_case.dart';

/// Wipes all local data in one transaction (wired to `AppDatabase.clearAll`).
typedef ClearLocalData = Future<void> Function();

/// Irreversibly deletes every habit, completion, journal entry and setting,
/// then cancels reminders, forgets the cached accent color and resets the
/// onboarding flag so the app opens on onboarding again.
class DeleteAllDataUseCase {
  const DeleteAllDataUseCase(
    this._clearLocalData,
    this._syncNotificationsUseCase,
    this._colorCache,
    this._onboarding, {
    AppLogService logger = const NoOpAppLogService(),
  }) : _logger = logger;

  final ClearLocalData _clearLocalData;
  final SyncNotificationsUseCase _syncNotificationsUseCase;
  final ActiveStarnyxColorCache _colorCache;
  final OnboardingPreferences _onboarding;
  final AppLogService _logger;

  Future<void> call() async {
    _logger.debug('DeleteAllDataUseCase', 'delete all begin');
    await _clearLocalData();
    // The data is already gone: a reminder that fails to cancel must not
    // report the whole delete as failed.
    try {
      await _syncNotificationsUseCase.cancelAll();
    } catch (error, stackTrace) {
      _logger.error(
        'DeleteAllDataUseCase',
        'cancel reminders failed (ignored)',
        error: error,
        stackTrace: stackTrace,
      );
    }
    await _colorCache.clear();
    await _onboarding.setCompleted(false);
    _logger.debug('DeleteAllDataUseCase', 'delete all success');
  }
}

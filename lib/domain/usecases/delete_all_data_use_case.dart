import 'package:starnyx/core/services/core_services.dart';
import 'package:starnyx/domain/usecases/sync_notifications_use_case.dart';

/// Wipes all local data in one transaction (wired to `AppDatabase.clearAll`).
typedef ClearLocalData = Future<void> Function();

/// Irreversibly deletes every habit, completion, journal entry and setting,
/// then cancels reminders and forgets the cached accent color.
///
/// After this the app shows the empty Habits tab. Extra first-run state
/// (e.g. an onboarding flag) should be reset here too.
class DeleteAllDataUseCase {
  const DeleteAllDataUseCase(
    this._clearLocalData,
    this._syncNotificationsUseCase,
    this._colorCache, {
    AppLogService logger = const NoOpAppLogService(),
  }) : _logger = logger;

  final ClearLocalData _clearLocalData;
  final SyncNotificationsUseCase _syncNotificationsUseCase;
  final ActiveStarnyxColorCache _colorCache;
  final AppLogService _logger;

  Future<void> call() async {
    _logger.debug('DeleteAllDataUseCase', 'delete all begin');
    await _clearLocalData();
    await _syncNotificationsUseCase.cancelAll();
    await _colorCache.clear();
    _logger.debug('DeleteAllDataUseCase', 'delete all success');
  }
}

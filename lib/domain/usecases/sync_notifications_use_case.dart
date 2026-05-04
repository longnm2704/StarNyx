import 'package:starnyx/core/services/core_services.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/repositories/starnyx_repository.dart';

/// Synchronizes notification schedules with current StarNyx reminder settings.
class SyncNotificationsUseCase {
  const SyncNotificationsUseCase(
    this._notificationService,
    this._starnyxRepository, {
    AppLogService logger = const NoOpAppLogService(),
  }) : _logger = logger;

  final NotificationService _notificationService;
  final StarNyxRepository _starnyxRepository;
  final AppLogService _logger;

  /// Sync schedule for a single saved StarNyx.
  Future<void> onStarnyxSaved(StarNyx starnyx) async {
    _logger.debug(
      'SyncNotificationsUseCase',
      'sync saved begin id=${starnyx.id} hasReminder=${starnyx.hasReminder} '
          'reminderTime=${starnyx.reminderTime}',
    );
    try {
      if (starnyx.hasReminder) {
        await _notificationService.updateReminder(starnyx);
        _logger.debug(
          'SyncNotificationsUseCase',
          'update reminder success id=${starnyx.id}',
        );
        return;
      }

      await _notificationService.cancelReminder(starnyx.id);
      _logger.debug(
        'SyncNotificationsUseCase',
        'cancel reminder success id=${starnyx.id}',
      );
    } catch (error, stackTrace) {
      _logger.error(
        'SyncNotificationsUseCase',
        'sync saved failed id=${starnyx.id}',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Remove schedule when a StarNyx is deleted.
  Future<void> onStarnyxDeleted(String starnyxId) async {
    _logger.debug(
      'SyncNotificationsUseCase',
      'delete sync begin id=$starnyxId',
    );
    await _notificationService.cancelReminder(starnyxId);
    _logger.debug(
      'SyncNotificationsUseCase',
      'delete sync success id=$starnyxId',
    );
  }

  /// Rebuild all schedules from local data (used after import).
  Future<void> rebuildAllFromLocalData() async {
    _logger.debug('SyncNotificationsUseCase', 'rebuild all begin');
    await _notificationService.cancelAllReminders();
    final starnyxs = await _starnyxRepository.getAllStarnyxs();

    for (final starnyx in starnyxs) {
      if (!starnyx.hasReminder) {
        continue;
      }
      await _notificationService.createReminder(starnyx);
    }
    _logger.debug(
      'SyncNotificationsUseCase',
      'rebuild all success starnyxs=${starnyxs.length}',
    );
  }
}

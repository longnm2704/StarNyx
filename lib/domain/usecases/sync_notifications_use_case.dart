import 'package:starnyx/core/services/core_services.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/repositories/starnyx_repository.dart';

/// Synchronizes notification schedules with current StarNyx reminder settings.
class SyncNotificationsUseCase {
  const SyncNotificationsUseCase(
    this._notificationService,
    this._starnyxRepository,
  );

  final NotificationService _notificationService;
  final StarNyxRepository _starnyxRepository;

  /// Sync schedule for a single saved StarNyx.
  Future<void> onStarnyxSaved(StarNyx starnyx) async {
    if (starnyx.hasReminder) {
      await _notificationService.updateReminder(starnyx);
      return;
    }

    await _notificationService.cancelReminder(starnyx.id);
  }

  /// Remove schedule when a StarNyx is deleted.
  Future<void> onStarnyxDeleted(String starnyxId) {
    return _notificationService.cancelReminder(starnyxId);
  }

  /// Rebuild all schedules from local data (used after import).
  Future<void> rebuildAllFromLocalData() async {
    await _notificationService.cancelAllReminders();
    final starnyxs = await _starnyxRepository.getAllStarnyxs();

    for (final starnyx in starnyxs) {
      if (!starnyx.hasReminder) {
        continue;
      }
      await _notificationService.createReminder(starnyx);
    }
  }
}

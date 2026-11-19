import 'package:starnyx/domain/repositories/starnyx_repository.dart';
import 'package:starnyx/domain/usecases/sync_notifications_use_case.dart';

/// Master reminder switch used by Settings.
///
/// Only flips `reminderEnabled`; `reminderTime` is kept so switching back on
/// restores every habit's own time. Habits that never had a time are skipped.
class SetAllRemindersEnabledUseCase {
  const SetAllRemindersEnabledUseCase(this._repository, this._sync);

  final StarNyxRepository _repository;
  final SyncNotificationsUseCase _sync;

  Future<void> call(bool enabled, {DateTime? now}) async {
    final starnyxs = await _repository.getAllStarnyxs();
    for (final starnyx in starnyxs) {
      if (starnyx.reminderTime == null || starnyx.reminderEnabled == enabled) {
        continue;
      }
      final updated = starnyx.copyWith(
        reminderEnabled: enabled,
        updatedAt: now ?? DateTime.now(),
      );
      await _repository.saveStarnyx(updated);
      await _sync.onStarnyxSaved(updated);
    }
  }
}

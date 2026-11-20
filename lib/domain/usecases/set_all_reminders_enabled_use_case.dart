import 'package:starnyx/core/services/paused_reminders_store.dart';
import 'package:starnyx/domain/repositories/starnyx_repository.dart';
import 'package:starnyx/domain/usecases/sync_notifications_use_case.dart';

/// Master reminder switch used by Settings.
///
/// Only flips `reminderEnabled`; `reminderTime` is kept so switching back on
/// restores every habit's own time. Habits that never had a time are skipped.
///
/// ponytail: off remembers which habits were on (in [PausedRemindersStore]);
/// on restores exactly those, so habits the user had turned off one by one
/// stay off. With nothing remembered (e.g. all were already off), on enables
/// every habit that has a time.
class SetAllRemindersEnabledUseCase {
  const SetAllRemindersEnabledUseCase(
    this._repository,
    this._sync, {
    PausedRemindersStore? pausedStore,
  }) : _pausedStore = pausedStore;

  final StarNyxRepository _repository;
  final SyncNotificationsUseCase _sync;
  final PausedRemindersStore? _pausedStore;

  Future<void> call(bool enabled, {DateTime? now}) async {
    final withTime = (await _repository.getAllStarnyxs())
        .where((starnyx) => starnyx.reminderTime != null)
        .toList();
    var targets = withTime;
    if (!enabled) {
      await _pausedStore?.write(
        withTime.where((s) => s.reminderEnabled).map((s) => s.id),
      );
    } else {
      final paused = _pausedStore?.read() ?? const <String>{};
      final restorable = withTime.where((s) => paused.contains(s.id)).toList();
      if (restorable.isNotEmpty) targets = restorable;
    }

    for (final starnyx in targets) {
      if (starnyx.reminderEnabled == enabled) continue;
      final updated = starnyx.copyWith(
        reminderEnabled: enabled,
        updatedAt: now ?? DateTime.now(),
      );
      await _repository.saveStarnyx(updated);
      await _sync.onStarnyxSaved(updated);
    }
    if (enabled) await _pausedStore?.write(const <String>[]);
  }
}

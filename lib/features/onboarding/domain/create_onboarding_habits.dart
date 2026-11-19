import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/usecases/domain_usecases.dart';

/// A starter habit ready to be saved: copy already localized, reminder
/// time (`HH:mm`) already chosen on the reminder setup step (STX-U022).
typedef OnboardingHabitDraft = ({
  String title,
  String description,
  String icon,
  String color,
  String reminderTime,
});

/// Creates every draft with a daily reminder and schedules it the same way
/// the habit form does (`CreateStarNyxUseCase` + `onStarnyxSaved`).
///
/// All-or-nothing: if any step fails, habits created so far are removed with
/// [deleteOnboardingHabits] and the error is rethrown.
Future<List<StarNyx>> createOnboardingHabits(
  List<OnboardingHabitDraft> drafts, {
  required CreateStarNyxUseCase create,
  required DeleteStarNyxUseCase delete,
  required SyncNotificationsUseCase sync,
  DateTime? now,
}) async {
  final created = <StarNyx>[];
  try {
    for (final draft in drafts) {
      final timestamp = now ?? DateTime.now();
      final starnyx = await create(
        title: draft.title,
        description: draft.description,
        color: draft.color,
        icon: draft.icon,
        startDate: timestamp,
        reminderEnabled: true,
        reminderTime: draft.reminderTime,
        now: timestamp,
      );
      created.add(starnyx);
      await sync.onStarnyxSaved(starnyx);
    }
    return created;
  } catch (_) {
    await deleteOnboardingHabits(created, delete: delete, sync: sync);
    rethrow;
  }
}

/// Best-effort removal of onboarding habits and their reminders (rollback,
/// or the user backing out of the completion screen).
Future<void> deleteOnboardingHabits(
  List<StarNyx> habits, {
  required DeleteStarNyxUseCase delete,
  required SyncNotificationsUseCase sync,
}) async {
  for (final habit in habits) {
    try {
      await sync.onStarnyxDeleted(habit.id);
    } catch (_) {}
    try {
      await delete(habit.id);
    } catch (_) {}
  }
}

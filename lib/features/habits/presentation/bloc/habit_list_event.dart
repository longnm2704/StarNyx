sealed class HabitListEvent {
  const HabitListEvent();
}

final class HabitListLoadRequested extends HabitListEvent {
  const HabitListLoadRequested();
}

final class HabitListReloadRequested extends HabitListEvent {
  const HabitListReloadRequested();
}

final class HabitListHabitSelected extends HabitListEvent {
  const HabitListHabitSelected(this.id);

  final String id;
}

final class HabitListOrderChanged extends HabitListEvent {
  const HabitListOrderChanged(this.orderedIds);

  final List<String> orderedIds;
}

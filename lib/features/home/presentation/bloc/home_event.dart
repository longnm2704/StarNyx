import 'package:equatable/equatable.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class HomeLoadRequested extends HomeEvent {
  const HomeLoadRequested();
}

class HomeReloadRequested extends HomeEvent {
  const HomeReloadRequested();
}

class HomeActiveStarnyxSelected extends HomeEvent {
  const HomeActiveStarnyxSelected(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

class HomeDaySelected extends HomeEvent {
  const HomeDaySelected(this.date);

  final DateTime date;

  @override
  List<Object?> get props => <Object?>[date];
}

class HomePreviousDayRequested extends HomeEvent {
  const HomePreviousDayRequested();
}

class HomeNextDayRequested extends HomeEvent {
  const HomeNextDayRequested();
}

class HomeJumpToTodayRequested extends HomeEvent {
  const HomeJumpToTodayRequested();
}

class HomeYearChanged extends HomeEvent {
  const HomeYearChanged(this.year);

  final int year;

  @override
  List<Object?> get props => <Object?>[year];
}

class HomeCompletionToggled extends HomeEvent {
  const HomeCompletionToggled();
}

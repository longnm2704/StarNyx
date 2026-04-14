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

import 'package:equatable/equatable.dart';
import 'package:starnyx/core/constants/enums.dart';
import 'package:starnyx/domain/entities/starnyx.dart';

enum HabitListStatus { initial, loading, success, failure }

const Object _unset = Object();

/// State for the full-screen habit list.
///
/// [selectionFeedbackCount] and [orderFeedbackCount] increment on every
/// attempt so the page can react exactly once per user action, even when the
/// user retries with the same result.
class HabitListState extends Equatable {
  const HabitListState({
    this.status = HabitListStatus.initial,
    this.habits = const <StarNyx>[],
    this.activeHabitId,
    this.completedTodayCount = 0,
    this.selectionStatus = AsyncStatus.idle,
    this.orderStatus = AsyncStatus.idle,
    this.selectionFeedbackCount = 0,
    this.orderFeedbackCount = 0,
  });

  final HabitListStatus status;
  final List<StarNyx> habits;
  final String? activeHabitId;
  final int completedTodayCount;
  final AsyncStatus selectionStatus;
  final AsyncStatus orderStatus;
  final int selectionFeedbackCount;
  final int orderFeedbackCount;

  bool get isEmpty => status == HabitListStatus.success && habits.isEmpty;

  StarNyx? get activeHabit {
    if (habits.isEmpty) {
      return null;
    }
    return habits.firstWhere(
      (habit) => habit.id == activeHabitId,
      orElse: () => habits.first,
    );
  }

  HabitListState copyWith({
    HabitListStatus? status,
    List<StarNyx>? habits,
    Object? activeHabitId = _unset,
    int? completedTodayCount,
    AsyncStatus? selectionStatus,
    AsyncStatus? orderStatus,
    int? selectionFeedbackCount,
    int? orderFeedbackCount,
  }) {
    return HabitListState(
      status: status ?? this.status,
      habits: habits ?? this.habits,
      activeHabitId: identical(activeHabitId, _unset)
          ? this.activeHabitId
          : activeHabitId as String?,
      completedTodayCount: completedTodayCount ?? this.completedTodayCount,
      selectionStatus: selectionStatus ?? this.selectionStatus,
      orderStatus: orderStatus ?? this.orderStatus,
      selectionFeedbackCount:
          selectionFeedbackCount ?? this.selectionFeedbackCount,
      orderFeedbackCount: orderFeedbackCount ?? this.orderFeedbackCount,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    habits,
    activeHabitId,
    completedTodayCount,
    selectionStatus,
    orderStatus,
    selectionFeedbackCount,
    orderFeedbackCount,
  ];
}

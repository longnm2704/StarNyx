import 'package:equatable/equatable.dart';
import 'package:starnyx/core/constants/enums.dart';
export 'package:starnyx/core/constants/enums.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/entities/starnyx_progress_stats.dart';

class HomeState extends Equatable {
  const HomeState({
    required this.status,
    required this.selectionStatus,
    required this.completionStatus,
    required this.starnyxs,
    required this.selectionFeedbackCount,
    required this.completionFeedbackCount,
    required this.selectedDate,
    required this.viewedYear,
    required this.completedDatesForViewedYear,
    this.activeStarnyxId,
    this.progressStats,
  });

  HomeState.initial()
    : this(
        status: HomeStatus.initial,
        selectionStatus: AsyncStatus.idle,
        completionStatus: AsyncStatus.idle,
        starnyxs: const <StarNyx>[],
        selectionFeedbackCount: 0,
        completionFeedbackCount: 0,
        selectedDate: DateTime(1970, 1, 1),
        viewedYear: 1970,
        completedDatesForViewedYear: const <DateTime>[],
      );

  final HomeStatus status;
  final AsyncStatus selectionStatus;
  final AsyncStatus completionStatus;
  final List<StarNyx> starnyxs;
  final String? activeStarnyxId;
  final int selectionFeedbackCount;
  final int completionFeedbackCount;
  final DateTime selectedDate;
  final int viewedYear;
  final List<DateTime> completedDatesForViewedYear;
  final StarNyxProgressStats? progressStats;

  bool get hasData => starnyxs.isNotEmpty;

  HomeState copyWith({
    HomeStatus? status,
    AsyncStatus? selectionStatus,
    AsyncStatus? completionStatus,
    List<StarNyx>? starnyxs,
    Object? activeStarnyxId = _unset,
    int? selectionFeedbackCount,
    int? completionFeedbackCount,
    DateTime? selectedDate,
    int? viewedYear,
    List<DateTime>? completedDatesForViewedYear,
    Object? progressStats = _unset,
  }) {
    return HomeState(
      status: status ?? this.status,
      selectionStatus: selectionStatus ?? this.selectionStatus,
      completionStatus: completionStatus ?? this.completionStatus,
      starnyxs: starnyxs ?? this.starnyxs,
      activeStarnyxId: identical(activeStarnyxId, _unset)
          ? this.activeStarnyxId
          : activeStarnyxId as String?,
      selectionFeedbackCount:
          selectionFeedbackCount ?? this.selectionFeedbackCount,
      completionFeedbackCount:
          completionFeedbackCount ?? this.completionFeedbackCount,
      selectedDate: selectedDate ?? this.selectedDate,
      viewedYear: viewedYear ?? this.viewedYear,
      completedDatesForViewedYear:
          completedDatesForViewedYear ?? this.completedDatesForViewedYear,
      progressStats: identical(progressStats, _unset)
          ? this.progressStats
          : progressStats as StarNyxProgressStats?,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    selectionStatus,
    completionStatus,
    starnyxs,
    activeStarnyxId,
    selectionFeedbackCount,
    completionFeedbackCount,
    selectedDate,
    viewedYear,
    completedDatesForViewedYear,
    progressStats,
  ];
}

const Object _unset = Object();

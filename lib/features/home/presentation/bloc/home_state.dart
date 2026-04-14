import 'package:equatable/equatable.dart';
import 'package:starnyx/domain/entities/starnyx.dart';

enum HomeStatus { initial, loading, success, failure }

enum HomeSelectionStatus { idle, inProgress, success, failure }

class HomeState extends Equatable {
  const HomeState({
    required this.status,
    required this.selectionStatus,
    required this.starnyxs,
    required this.selectionFeedbackCount,
    this.activeStarnyxId,
  });

  const HomeState.initial()
    : this(
        status: HomeStatus.initial,
        selectionStatus: HomeSelectionStatus.idle,
        starnyxs: const <StarNyx>[],
        selectionFeedbackCount: 0,
      );

  final HomeStatus status;
  final HomeSelectionStatus selectionStatus;
  final List<StarNyx> starnyxs;
  final String? activeStarnyxId;
  final int selectionFeedbackCount;

  bool get hasData => starnyxs.isNotEmpty;

  HomeState copyWith({
    HomeStatus? status,
    HomeSelectionStatus? selectionStatus,
    List<StarNyx>? starnyxs,
    Object? activeStarnyxId = _unset,
    int? selectionFeedbackCount,
  }) {
    return HomeState(
      status: status ?? this.status,
      selectionStatus: selectionStatus ?? this.selectionStatus,
      starnyxs: starnyxs ?? this.starnyxs,
      activeStarnyxId: identical(activeStarnyxId, _unset)
          ? this.activeStarnyxId
          : activeStarnyxId as String?,
      selectionFeedbackCount:
          selectionFeedbackCount ?? this.selectionFeedbackCount,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    selectionStatus,
    starnyxs,
    activeStarnyxId,
    selectionFeedbackCount,
  ];
}

const Object _unset = Object();

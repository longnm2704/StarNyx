import 'package:equatable/equatable.dart';
import 'package:starnyx/core/constants/enums.dart';
import 'package:starnyx/domain/entities/overview_stats.dart';

const Object _unset = Object();

class OverviewState extends Equatable {
  const OverviewState({
    required this.year,
    this.status = OverviewStatus.initial,
    this.range = OverviewRange.week,
    this.stats,
  });

  final OverviewStatus status;
  final int year;
  final OverviewRange range;
  final OverviewStats? stats;

  bool get isEmpty =>
      status == OverviewStatus.success && (stats?.habits.isEmpty ?? true);

  bool get hasData => stats?.habits.isNotEmpty ?? false;

  OverviewState copyWith({
    OverviewStatus? status,
    int? year,
    OverviewRange? range,
    Object? stats = _unset,
  }) {
    return OverviewState(
      status: status ?? this.status,
      year: year ?? this.year,
      range: range ?? this.range,
      stats: identical(stats, _unset) ? this.stats : stats as OverviewStats?,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, year, range, stats];
}

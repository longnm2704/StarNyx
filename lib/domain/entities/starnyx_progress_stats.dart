import 'package:equatable/equatable.dart';

// Aggregated progress metrics shown on the home screen for one StarNyx.
class StarNyxProgressStats extends Equatable {
  const StarNyxProgressStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCompletedCount,
    required this.completedCountForYear,
    required this.validDayCountForYear,
    required this.completionRateForYear,
  });

  final int currentStreak;
  final int longestStreak;
  final int totalCompletedCount;
  final int completedCountForYear;
  final int validDayCountForYear;
  final double completionRateForYear;

  @override
  List<Object?> get props => <Object?>[
    currentStreak,
    longestStreak,
    totalCompletedCount,
    completedCountForYear,
    validDayCountForYear,
    completionRateForYear,
  ];
}

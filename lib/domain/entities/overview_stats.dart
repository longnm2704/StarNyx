import 'package:equatable/equatable.dart';
import 'package:starnyx/core/constants/enums.dart';

/// One habit's progress inside the Overview aggregation.
///
/// The yearly fields mirror [StarNyxProgressStats] one-to-one so the Overview
/// screen can show the same numbers as the Habits tab without recomputing
/// streak math in presentation code.
class OverviewHabitStats extends Equatable {
  const OverviewHabitStats({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.currentStreak,
    required this.longestStreak,
    required this.completedCountForYear,
    required this.validDayCountForYear,
    required this.completionRateForYear,
    this.completedCountInRange = 0,
    this.validDayCountInRange = 0,
  });

  final String id;
  final String title;
  final String icon;
  final String color;
  final int currentStreak;
  final int longestStreak;
  final int completedCountForYear;
  final int validDayCountForYear;
  final double completionRateForYear;

  /// Lit / valid days inside the selected Overview range (week, month, year).
  final int completedCountInRange;
  final int validDayCountInRange;

  double get completionRateInRange => validDayCountInRange == 0
      ? 0
      : completedCountInRange / validDayCountInRange;

  @override
  List<Object?> get props => <Object?>[
    id,
    title,
    icon,
    color,
    currentStreak,
    longestStreak,
    completedCountForYear,
    validDayCountForYear,
    completionRateForYear,
    completedCountInRange,
    validDayCountInRange,
  ];
}

/// Aggregated stats for the Overview tab.
///
/// [totalLitDays] and [totalValidDays] are habit-days, not calendar days: a day
/// where two habits were completed counts twice. That matches the product rule
/// "sum of completed / sum of valid days" for the overall completion rate.
class OverviewStats extends Equatable {
  const OverviewStats({
    required this.year,
    required this.range,
    required this.habitCount,
    required this.totalLitDays,
    required this.totalValidDays,
    required this.overallCompletionRate,
    required this.bestCurrentStreak,
    required this.bestLongestStreak,
    required this.habits,
    required this.dailyLitCounts,
    required this.dailyValidCounts,
    this.rangeStart,
    this.rangeEnd,
  });

  /// Empty overview for a database with no habits (or a window with no days).
  factory OverviewStats.empty({
    required int year,
    required OverviewRange range,
    DateTime? rangeStart,
    DateTime? rangeEnd,
  }) {
    return OverviewStats(
      year: year,
      range: range,
      habitCount: 0,
      totalLitDays: 0,
      totalValidDays: 0,
      overallCompletionRate: 0,
      bestCurrentStreak: 0,
      bestLongestStreak: 0,
      habits: const <OverviewHabitStats>[],
      dailyLitCounts: const <DateTime, int>{},
      dailyValidCounts: const <DateTime, int>{},
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
    );
  }

  final int year;
  final OverviewRange range;
  final int habitCount;
  final int totalLitDays;
  final int totalValidDays;
  final double overallCompletionRate;
  final int bestCurrentStreak;
  final int bestLongestStreak;
  final List<OverviewHabitStats> habits;

  /// Number of completed habits per day inside the selected window.
  final Map<DateTime, int> dailyLitCounts;

  /// Number of habits that had a valid tracking day per day inside the window.
  /// Used to colour the discipline heatmap without penalising habits that had
  /// not started yet.
  final Map<DateTime, int> dailyValidCounts;

  /// Inclusive window represented by the heatmap. Null when the selected
  /// year/range combination contains no valid dates (for example a future
  /// year).
  final DateTime? rangeStart;
  final DateTime? rangeEnd;

  bool get isEmpty => habits.isEmpty;

  @override
  List<Object?> get props => <Object?>[
    year,
    range,
    habitCount,
    totalLitDays,
    totalValidDays,
    overallCompletionRate,
    bestCurrentStreak,
    bestLongestStreak,
    habits,
    dailyLitCounts,
    dailyValidCounts,
    rangeStart,
    rangeEnd,
  ];
}

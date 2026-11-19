import 'package:starnyx/core/constants/enums.dart';
import 'package:starnyx/core/services/app_log_service.dart';
import 'package:starnyx/core/utils/date_utils.dart';
import 'package:starnyx/domain/entities/overview_stats.dart';
import 'package:starnyx/domain/repositories/completion_repository.dart';
import 'package:starnyx/domain/usecases/load_starnyx_progress_stats_use_case.dart';
import 'package:starnyx/domain/usecases/load_starnyxs_use_case.dart';

/// Aggregates every habit into one Overview snapshot.
///
/// Yearly per-habit numbers come from [LoadStarNyxProgressStatsUseCase] so the
/// streak rules stay in one place. The selected [range] only narrows the
/// aggregate totals and the heatmap window; per-habit rows always report the
/// selected [year] to match the Overview design.
class LoadOverviewStatsUseCase {
  const LoadOverviewStatsUseCase(
    this._loadStarnyxsUseCase,
    this._completionRepository,
    this._loadStarNyxProgressStatsUseCase, {
    AppLogService logger = const NoOpAppLogService(),
  }) : _logger = logger;

  final LoadStarnyxsUseCase _loadStarnyxsUseCase;
  final CompletionRepository _completionRepository;
  final LoadStarNyxProgressStatsUseCase _loadStarNyxProgressStatsUseCase;
  final AppLogService _logger;

  Future<OverviewStats> call({
    required int year,
    required OverviewRange range,
    DateTime? today,
  }) async {
    final normalizedToday = DateUtils.nowDate(today);
    final window = _windowFor(year: year, range: range, today: normalizedToday);
    _logger.debug(
      'LoadOverviewStatsUseCase',
      'load begin year=$year range=$range today=$normalizedToday',
    );

    final habits = await _loadStarnyxsUseCase();
    if (habits.isEmpty) {
      _logger.debug('LoadOverviewStatsUseCase', 'load success: no habits');
      return OverviewStats.empty(
        year: year,
        range: range,
        rangeStart: window?.start,
        rangeEnd: window?.end,
      );
    }

    final habitStats = <OverviewHabitStats>[];
    final dailyLitCounts = <DateTime, int>{};
    final dailyValidCounts = <DateTime, int>{};
    var totalLitDays = 0;
    var totalValidDays = 0;
    var bestCurrentStreak = 0;
    var bestLongestStreak = 0;

    for (final habit in habits) {
      final yearlyStats = await _loadStarNyxProgressStatsUseCase(
        starnyxId: habit.id,
        year: year,
        today: normalizedToday,
      );
      habitStats.add(
        OverviewHabitStats(
          id: habit.id,
          title: habit.title,
          icon: habit.icon,
          color: habit.color,
          currentStreak: yearlyStats.currentStreak,
          longestStreak: yearlyStats.longestStreak,
          completedCountForYear: yearlyStats.completedCountForYear,
          validDayCountForYear: yearlyStats.validDayCountForYear,
          completionRateForYear: yearlyStats.completionRateForYear,
        ),
      );
      if (yearlyStats.currentStreak > bestCurrentStreak) {
        bestCurrentStreak = yearlyStats.currentStreak;
      }
      if (yearlyStats.longestStreak > bestLongestStreak) {
        bestLongestStreak = yearlyStats.longestStreak;
      }

      if (window == null) {
        continue;
      }

      final validStart = DateUtils.maxDate(window.start, habit.startDate);
      if (window.end.isBefore(validStart)) {
        continue;
      }

      for (
        var day = validStart;
        !day.isAfter(window.end);
        day = day.add(const Duration(days: 1))
      ) {
        dailyValidCounts[day] = (dailyValidCounts[day] ?? 0) + 1;
        totalValidDays += 1;
      }

      final completions = await _completionRepository.getCompletionsForStarnyx(
        habit.id,
      );
      final completedDates = completions
          .where((completion) => completion.completed)
          .map((completion) => DateUtils.dateOnly(completion.date))
          .toSet();
      for (final date in completedDates) {
        if (date.isBefore(validStart) || date.isAfter(window.end)) {
          continue;
        }
        dailyLitCounts[date] = (dailyLitCounts[date] ?? 0) + 1;
        totalLitDays += 1;
      }
    }

    final overallCompletionRate = totalValidDays == 0
        ? 0.0
        : totalLitDays / totalValidDays;
    _logger.debug(
      'LoadOverviewStatsUseCase',
      'load success habits=${habits.length} lit=$totalLitDays '
          'valid=$totalValidDays rate=$overallCompletionRate',
    );

    return OverviewStats(
      year: year,
      range: range,
      habitCount: habits.length,
      totalLitDays: totalLitDays,
      totalValidDays: totalValidDays,
      overallCompletionRate: overallCompletionRate,
      bestCurrentStreak: bestCurrentStreak,
      bestLongestStreak: bestLongestStreak,
      habits: List<OverviewHabitStats>.unmodifiable(habitStats),
      dailyLitCounts: _sortedByDate(dailyLitCounts),
      dailyValidCounts: _sortedByDate(dailyValidCounts),
      rangeStart: window?.start,
      rangeEnd: window?.end,
    );
  }

  /// Returns the inclusive window for [range], clipped to [year] and to the
  /// current day. Week is a rolling seven-day window ending today; month is
  /// the current calendar month up to today; year is the selected year up to
  /// today (or its final day for past years).
  _OverviewWindow? _windowFor({
    required int year,
    required OverviewRange range,
    required DateTime today,
  }) {
    final yearStart = DateUtils.startOfYear(year);
    final yearEnd = DateUtils.endOfYear(year);
    final (rawStart, rawEnd) = switch (range) {
      OverviewRange.week => (today.subtract(const Duration(days: 6)), today),
      OverviewRange.month => (DateTime(today.year, today.month, 1), today),
      OverviewRange.year => (yearStart, yearEnd),
    };

    final start = DateUtils.maxDate(rawStart, yearStart);
    final end = DateUtils.minDate(DateUtils.minDate(rawEnd, today), yearEnd);
    if (end.isBefore(start)) {
      return null;
    }
    return _OverviewWindow(start: start, end: end);
  }

  Map<DateTime, int> _sortedByDate(Map<DateTime, int> counts) {
    final dates = counts.keys.toList(growable: false)..sort();
    return <DateTime, int>{for (final date in dates) date: counts[date]!};
  }
}

class _OverviewWindow {
  const _OverviewWindow({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

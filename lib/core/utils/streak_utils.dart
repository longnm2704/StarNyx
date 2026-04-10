import 'package:starnyx/core/utils/date_utils.dart';

// Shared progress metrics used by stats and yearly views.
abstract final class StreakUtils {
  static int currentStreak({
    required Iterable<DateTime> completionDates,
    DateTime? today,
  }) {
    final normalizedToday = DateUtils.nowDate(today);
    final completedDays = _normalizedDayKeys(completionDates);

    // Spec rule:
    // - if today is completed, count backwards from today
    // - otherwise, if yesterday is completed, count backwards from yesterday
    // - otherwise the current streak is 0
    if (completedDays.contains(_dayKey(normalizedToday))) {
      return _countBackwardsFrom(
        start: normalizedToday,
        completedDays: completedDays,
      );
    }

    final yesterday = normalizedToday.subtract(const Duration(days: 1));
    if (completedDays.contains(_dayKey(yesterday))) {
      return _countBackwardsFrom(
        start: yesterday,
        completedDays: completedDays,
      );
    }

    return 0;
  }

  static int longestStreak(Iterable<DateTime> completionDates) {
    final sortedDays = completionDates.map(DateUtils.dateOnly).toSet().toList()
      ..sort();

    if (sortedDays.isEmpty) {
      return 0;
    }

    var longest = 1;
    var current = 1;

    for (var index = 1; index < sortedDays.length; index++) {
      final diff = sortedDays[index].difference(sortedDays[index - 1]).inDays;

      if (diff == 1) {
        current += 1;
      } else {
        current = 1;
      }

      if (current > longest) {
        longest = current;
      }
    }

    return longest;
  }

  static int validDayCountForYear({
    required DateTime startDate,
    required int year,
    DateTime? today,
  }) {
    final range = DateUtils.validDateRangeForYear(
      startDate: startDate,
      year: year,
      today: today,
    );

    return range?.dayCount ?? 0;
  }

  static int completedCountForYear({
    required Iterable<DateTime> completionDates,
    required DateTime startDate,
    required int year,
    DateTime? today,
  }) {
    final range = DateUtils.validDateRangeForYear(
      startDate: startDate,
      year: year,
      today: today,
    );

    if (range == null) {
      return 0;
    }

    return completionDates
        .map(DateUtils.dateOnly)
        .toSet()
        .where(range.contains)
        .length;
  }

  static double completionRateForYear({
    required Iterable<DateTime> completionDates,
    required DateTime startDate,
    required int year,
    DateTime? today,
  }) {
    // Returning 0 matches the product rule for years with no valid tracking dates.
    final validDayCount = validDayCountForYear(
      startDate: startDate,
      year: year,
      today: today,
    );

    if (validDayCount == 0) {
      return 0;
    }

    final completedCount = completedCountForYear(
      completionDates: completionDates,
      startDate: startDate,
      year: year,
      today: today,
    );

    return completedCount / validDayCount;
  }

  static int _countBackwardsFrom({
    required DateTime start,
    required Set<int> completedDays,
  }) {
    var cursor = start;
    var streak = 0;

    while (completedDays.contains(_dayKey(cursor))) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  static Set<int> _normalizedDayKeys(Iterable<DateTime> dates) {
    return dates.map((value) => _dayKey(DateUtils.dateOnly(value))).toSet();
  }

  static int _dayKey(DateTime value) =>
      DateUtils.dateOnly(value).millisecondsSinceEpoch;
}

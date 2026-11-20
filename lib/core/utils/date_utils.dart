import 'package:intl/intl.dart';

// Inclusive range used by yearly metrics that count both start and end dates.
class InclusiveDateRange {
  const InclusiveDateRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  // Product metrics count both endpoints as valid days.
  int get dayCount => DateUtils.daysBetween(start, end) + 1;

  bool contains(DateTime value) {
    final normalizedValue = DateUtils.dateOnly(value);
    return !normalizedValue.isBefore(start) && !normalizedValue.isAfter(end);
  }
}

// Shared date-only helpers for rules that must ignore time-of-day.
abstract final class DateUtils {
  static DateTime nowDate([DateTime? now]) => dateOnly(now ?? DateTime.now());

  /// Locale-aware short date (e.g. `11/20/2026` en, `20/11/2026` vi,
  /// `2026/11/20` ja).
  static String formatShortDate(DateTime value, String locale) {
    return DateFormat.yMd(locale).format(value);
  }

  /// Locale-aware short date plus 24h time.
  static String formatShortDateTime(DateTime value, String locale) {
    return DateFormat.yMd(locale).addPattern('HH:mm').format(value);
  }

  static DateTime dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  /// Calendar-day arithmetic on local dates. Adding `Duration(days: n)` to a
  /// local midnight lands on the wrong day across a DST change (23/25-hour
  /// days); building the date from its fields does not.
  static DateTime addDays(DateTime value, int days) {
    return DateTime(value.year, value.month, value.day + days);
  }

  /// Whole calendar days from [from] to [to] (negative when [to] is earlier),
  /// ignoring time of day and DST.
  static int daysBetween(DateTime from, DateTime to) {
    return DateTime.utc(
      to.year,
      to.month,
      to.day,
    ).difference(DateTime.utc(from.year, from.month, from.day)).inDays;
  }

  static bool isSameDate(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  static DateTime startOfYear(int year) => DateTime(year, 1, 1);

  static DateTime endOfYear(int year) => DateTime(year, 12, 31);

  static bool isLeapYear(int year) {
    if (year % 400 == 0) {
      return true;
    }

    if (year % 100 == 0) {
      return false;
    }

    return year % 4 == 0;
  }

  static int daysInYear(int year) => isLeapYear(year) ? 366 : 365;

  static DateTime maxDate(DateTime left, DateTime right) {
    return left.isAfter(right) ? left : right;
  }

  static DateTime minDate(DateTime left, DateTime right) {
    return left.isBefore(right) ? left : right;
  }

  static bool isFutureDate(DateTime value, {DateTime? today}) {
    return dateOnly(value).isAfter(nowDate(today));
  }

  static bool isBeforeStartDate(DateTime value, {required DateTime startDate}) {
    return dateOnly(value).isBefore(dateOnly(startDate));
  }

  static bool isEditableWithinDays(
    DateTime value, {
    required int days,
    DateTime? today,
  }) {
    final normalizedToday = nowDate(today);
    final normalizedValue = dateOnly(value);
    final diff = daysBetween(normalizedValue, normalizedToday);

    return diff >= 0 && diff < days;
  }

  static InclusiveDateRange? validDateRangeForYear({
    required DateTime startDate,
    required int year,
    DateTime? today,
  }) {
    // Completion rate only uses valid dates inside the viewed year.
    final normalizedStartDate = dateOnly(startDate);
    final normalizedToday = nowDate(today);
    final rangeStart = maxDate(normalizedStartDate, startOfYear(year));
    final rangeEnd = minDate(normalizedToday, endOfYear(year));

    if (rangeEnd.isBefore(rangeStart)) {
      return null;
    }

    return InclusiveDateRange(start: rangeStart, end: rangeEnd);
  }
}

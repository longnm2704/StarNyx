class InclusiveDateRange {
  const InclusiveDateRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  int get dayCount => end.difference(start).inDays + 1;

  bool contains(DateTime value) {
    final normalizedValue = DateUtils.dateOnly(value);
    return !normalizedValue.isBefore(start) && !normalizedValue.isAfter(end);
  }
}

abstract final class DateUtils {
  static DateTime nowDate([DateTime? now]) => dateOnly(now ?? DateTime.now());

  static DateTime dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
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
    final diff = normalizedToday.difference(normalizedValue).inDays;

    return diff >= 0 && diff < days;
  }

  static InclusiveDateRange? validDateRangeForYear({
    required DateTime startDate,
    required int year,
    DateTime? today,
  }) {
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

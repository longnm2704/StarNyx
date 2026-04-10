import 'package:starnyx/core/utils/date_utils.dart';

// Helpers for parsing and normalizing reminder times.
abstract final class ReminderTimeUtils {
  static final RegExp _timePattern = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');

  static DateTime roundToNearestSlot(DateTime input) {
    // Reminder defaults are constrained to :00 and :30 slots.
    final normalized = DateUtils.dateOnly(input);

    if (input.minute <= 14) {
      return DateTime(
        normalized.year,
        normalized.month,
        normalized.day,
        input.hour,
      );
    }

    if (input.minute <= 44) {
      return DateTime(
        normalized.year,
        normalized.month,
        normalized.day,
        input.hour,
        30,
      );
    }

    return DateTime(
      normalized.year,
      normalized.month,
      normalized.day,
      input.hour + 1,
    );
  }

  static bool isValidTimeString(String value) {
    return _timePattern.hasMatch(value);
  }

  static DateTime? parseTimeString(String value, {DateTime? anchorDate}) {
    final match = _timePattern.firstMatch(value);
    if (match == null) {
      return null;
    }

    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final date = DateUtils.dateOnly(anchorDate ?? DateTime.now());

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  static String formatTime(DateTime value) {
    final hours = value.hour.toString().padLeft(2, '0');
    final minutes = value.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}

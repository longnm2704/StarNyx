import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/core/utils/date_utils.dart';
import 'package:starnyx/core/utils/reminder_time_utils.dart';

// Covers date-only rules and exact reminder time handling.
void main() {
  group('DateUtils', () {
    test('returns valid date range for a viewed year', () {
      final range = DateUtils.validDateRangeForYear(
        startDate: DateTime(2026, 3, 15),
        year: 2026,
        today: DateTime(2026, 4, 10),
      );

      expect(range, isNotNull);
      expect(range!.start, DateTime(2026, 3, 15));
      expect(range.end, DateTime(2026, 4, 10));
      expect(range.dayCount, 27);
    });

    test('returns null when start date is after viewed range end', () {
      final range = DateUtils.validDateRangeForYear(
        startDate: DateTime(2027, 1, 1),
        year: 2026,
        today: DateTime(2026, 4, 10),
      );

      expect(range, isNull);
    });

    test('checks 7-day edit lock inclusively from today backwards', () {
      expect(
        DateUtils.isEditableWithinDays(
          DateTime(2026, 4, 10),
          days: 7,
          today: DateTime(2026, 4, 10),
        ),
        isTrue,
      );
      expect(
        DateUtils.isEditableWithinDays(
          DateTime(2026, 4, 4),
          days: 7,
          today: DateTime(2026, 4, 10),
        ),
        isTrue,
      );
      expect(
        DateUtils.isEditableWithinDays(
          DateTime(2026, 4, 3),
          days: 7,
          today: DateTime(2026, 4, 10),
        ),
        isFalse,
      );
    });
  });

  group('ReminderTimeUtils', () {
    test('parses and formats exact HH:mm values without rounding', () {
      final parsed = ReminderTimeUtils.parseTimeString(
        '15:39',
        anchorDate: DateTime(2026, 4, 10),
      );

      expect(parsed, DateTime(2026, 4, 10, 15, 39));
      expect(ReminderTimeUtils.formatTime(parsed!), '15:39');
    });
  });
}

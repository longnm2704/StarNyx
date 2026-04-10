import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/core/utils/streak_utils.dart';

// Covers streak and completion-rate helpers used by stats.
void main() {
  group('StreakUtils', () {
    test('calculates current streak from today when today is completed', () {
      final streak = StreakUtils.currentStreak(
        completionDates: <DateTime>[
          DateTime(2026, 4, 8),
          DateTime(2026, 4, 9),
          DateTime(2026, 4, 10),
        ],
        today: DateTime(2026, 4, 10),
      );

      expect(streak, 3);
    });

    test(
      'calculates current streak from yesterday when today is not completed',
      () {
        final streak = StreakUtils.currentStreak(
          completionDates: <DateTime>[
            DateTime(2026, 4, 7),
            DateTime(2026, 4, 8),
            DateTime(2026, 4, 9),
          ],
          today: DateTime(2026, 4, 10),
        );

        expect(streak, 3);
      },
    );

    test('calculates longest streak', () {
      final streak = StreakUtils.longestStreak(<DateTime>[
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 2),
        DateTime(2026, 1, 5),
        DateTime(2026, 1, 6),
        DateTime(2026, 1, 7),
      ]);

      expect(streak, 3);
    });

    test('calculates completion rate using valid day range of viewed year', () {
      final rate = StreakUtils.completionRateForYear(
        completionDates: <DateTime>[
          DateTime(2026, 3, 15),
          DateTime(2026, 3, 16),
          DateTime(2026, 4, 10),
        ],
        startDate: DateTime(2026, 3, 15),
        year: 2026,
        today: DateTime(2026, 4, 10),
      );

      expect(rate, closeTo(3 / 27, 0.0001));
    });
  });
}

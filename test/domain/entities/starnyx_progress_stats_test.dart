import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/domain/entities/starnyx_progress_stats.dart';

// Locks the value semantics of the aggregated progress stats model.
void main() {
  test('supports value equality', () {
    const first = StarNyxProgressStats(
      currentStreak: 3,
      longestStreak: 8,
      totalCompletedCount: 12,
      completedCountForYear: 10,
      validDayCountForYear: 20,
      completionRateForYear: 0.5,
    );
    const second = StarNyxProgressStats(
      currentStreak: 3,
      longestStreak: 8,
      totalCompletedCount: 12,
      completedCountForYear: 10,
      validDayCountForYear: 20,
      completionRateForYear: 0.5,
    );

    expect(first, second);
  });
}

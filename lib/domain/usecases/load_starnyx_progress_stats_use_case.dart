import 'package:starnyx/core/utils/streak_utils.dart';
import 'package:starnyx/domain/entities/starnyx_progress_stats.dart';
import 'package:starnyx/domain/repositories/starnyx_repository.dart';
import 'package:starnyx/domain/repositories/completion_repository.dart';

// Loads progress metrics for one StarNyx using the finalized streak rules.
class LoadStarNyxProgressStatsUseCase {
  const LoadStarNyxProgressStatsUseCase(
    this._starnyxRepository,
    this._completionRepository,
  );

  final StarNyxRepository _starnyxRepository;
  final CompletionRepository _completionRepository;

  Future<StarNyxProgressStats> call({
    required String starnyxId,
    required int year,
    DateTime? today,
  }) async {
    final starnyx = await _starnyxRepository.getStarnyxById(starnyxId);
    if (starnyx == null) {
      throw StateError('StarNyx with id $starnyxId was not found.');
    }

    final completions = await _completionRepository.getCompletionsForStarnyx(
      starnyxId,
    );
    final completedDates = completions
        .where((completion) => completion.completed)
        .map((completion) => completion.date)
        .toList(growable: false);

    return StarNyxProgressStats(
      currentStreak: StreakUtils.currentStreak(
        completionDates: completedDates,
        today: today,
      ),
      longestStreak: StreakUtils.longestStreak(completedDates),
      totalCompletedCount: completedDates.toSet().length,
      completedCountForYear: StreakUtils.completedCountForYear(
        completionDates: completedDates,
        startDate: starnyx.startDate,
        year: year,
        today: today,
      ),
      validDayCountForYear: StreakUtils.validDayCountForYear(
        startDate: starnyx.startDate,
        year: year,
        today: today,
      ),
      completionRateForYear: StreakUtils.completionRateForYear(
        completionDates: completedDates,
        startDate: starnyx.startDate,
        year: year,
        today: today,
      ),
    );
  }
}

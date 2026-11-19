import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/core/constants/enums.dart';
import 'package:starnyx/domain/entities/domain_entities.dart';
import 'package:starnyx/domain/repositories/domain_repositories.dart';
import 'package:starnyx/domain/usecases/load_overview_stats_use_case.dart';
import 'package:starnyx/domain/usecases/load_starnyx_progress_stats_use_case.dart';
import 'package:starnyx/domain/usecases/load_starnyxs_use_case.dart';

void main() {
  late _InMemoryStarNyxRepository starnyxRepository;
  late _InMemoryCompletionRepository completionRepository;
  late LoadOverviewStatsUseCase useCase;

  setUp(() {
    starnyxRepository = _InMemoryStarNyxRepository();
    completionRepository = _InMemoryCompletionRepository();
    useCase = LoadOverviewStatsUseCase(
      LoadStarnyxsUseCase(starnyxRepository),
      completionRepository,
      LoadStarNyxProgressStatsUseCase(starnyxRepository, completionRepository),
    );
  });

  test('returns empty stats for an empty database', () async {
    final stats = await useCase(
      year: 2026,
      range: OverviewRange.year,
      today: DateTime(2026, 4, 19),
    );

    expect(stats.year, 2026);
    expect(stats.range, OverviewRange.year);
    expect(stats.habitCount, 0);
    expect(stats.totalLitDays, 0);
    expect(stats.totalValidDays, 0);
    expect(stats.overallCompletionRate, 0);
    expect(stats.bestCurrentStreak, 0);
    expect(stats.bestLongestStreak, 0);
    expect(stats.habits, isEmpty);
    expect(stats.dailyLitCounts, isEmpty);
    expect(stats.dailyValidCounts, isEmpty);
    expect(stats.rangeStart, DateTime(2026, 1, 1));
    expect(stats.rangeEnd, DateTime(2026, 4, 19));
  });

  test('aggregates one habit and narrows totals by range', () async {
    await starnyxRepository.saveStarnyx(
      _habit(id: 'habit-1', title: 'Hydrate', startDate: DateTime(2026, 4, 1)),
    );
    for (final day in <int>[17, 18, 19]) {
      await completionRepository.saveCompletion(
        Completion(
          starnyxId: 'habit-1',
          date: DateTime(2026, 4, day),
          completed: true,
        ),
      );
    }

    final yearStats = await useCase(
      year: 2026,
      range: OverviewRange.year,
      today: DateTime(2026, 4, 19),
    );

    expect(yearStats.habitCount, 1);
    expect(yearStats.totalLitDays, 3);
    expect(yearStats.totalValidDays, 19);
    expect(yearStats.overallCompletionRate, closeTo(3 / 19, 0.0001));
    expect(yearStats.bestCurrentStreak, 3);
    expect(yearStats.bestLongestStreak, 3);
    expect(yearStats.habits, hasLength(1));
    expect(yearStats.habits.single.id, 'habit-1');
    expect(yearStats.habits.single.icon, 'star');
    expect(yearStats.habits.single.completedCountForYear, 3);
    expect(yearStats.habits.single.validDayCountForYear, 19);
    expect(
      yearStats.habits.single.completionRateForYear,
      closeTo(3 / 19, 0.0001),
    );
    expect(yearStats.dailyValidCounts, hasLength(19));
    expect(yearStats.dailyLitCounts, <DateTime, int>{
      DateTime(2026, 4, 17): 1,
      DateTime(2026, 4, 18): 1,
      DateTime(2026, 4, 19): 1,
    });

    final weekStats = await useCase(
      year: 2026,
      range: OverviewRange.week,
      today: DateTime(2026, 4, 19),
    );

    expect(weekStats.rangeStart, DateTime(2026, 4, 13));
    expect(weekStats.rangeEnd, DateTime(2026, 4, 19));
    expect(weekStats.totalLitDays, 3);
    expect(weekStats.totalValidDays, 7);
    expect(weekStats.overallCompletionRate, closeTo(3 / 7, 0.0001));
  });

  test('sums multiple habits with different start dates', () async {
    await starnyxRepository.saveStarnyx(
      _habit(id: 'habit-1', title: 'Hydrate', startDate: DateTime(2026, 4, 1)),
    );
    await starnyxRepository.saveStarnyx(
      _habit(
        id: 'habit-2',
        title: 'Read',
        startDate: DateTime(2026, 4, 15),
        icon: 'book',
      ),
    );
    for (final date in <DateTime>[
      DateTime(2026, 4, 10),
      DateTime(2026, 4, 11),
    ]) {
      await completionRepository.saveCompletion(
        Completion(starnyxId: 'habit-1', date: date, completed: true),
      );
    }
    for (final date in <DateTime>[
      DateTime(2026, 4, 16),
      DateTime(2026, 4, 19),
      DateTime(2026, 4, 20),
    ]) {
      await completionRepository.saveCompletion(
        Completion(starnyxId: 'habit-2', date: date, completed: true),
      );
    }

    final stats = await useCase(
      year: 2026,
      range: OverviewRange.year,
      today: DateTime(2026, 4, 20),
    );

    expect(stats.habitCount, 2);
    expect(stats.totalLitDays, 5);
    expect(stats.totalValidDays, 26);
    expect(stats.overallCompletionRate, closeTo(5 / 26, 0.0001));
    expect(stats.bestCurrentStreak, 2);
    expect(stats.bestLongestStreak, 2);
    expect(stats.habits.map((habit) => habit.id), <String>[
      'habit-1',
      'habit-2',
    ]);
    expect(stats.habits[0].completedCountForYear, 2);
    expect(stats.habits[0].validDayCountForYear, 20);
    expect(stats.habits[1].completedCountForYear, 3);
    expect(stats.habits[1].validDayCountForYear, 6);
    expect(stats.habits[1].icon, 'book');
    expect(stats.dailyValidCounts[DateTime(2026, 4, 14)], 1);
    expect(stats.dailyValidCounts[DateTime(2026, 4, 15)], 2);
    expect(stats.dailyLitCounts[DateTime(2026, 4, 20)], 1);
  });

  test('keeps year boundaries separate for stats and windows', () async {
    await starnyxRepository.saveStarnyx(
      _habit(
        id: 'habit-1',
        title: 'Hydrate',
        startDate: DateTime(2025, 12, 20),
      ),
    );
    for (final date in <DateTime>[
      DateTime(2025, 12, 30),
      DateTime(2025, 12, 31),
      DateTime(2026, 1, 1),
      DateTime(2026, 1, 2),
    ]) {
      await completionRepository.saveCompletion(
        Completion(starnyxId: 'habit-1', date: date, completed: true),
      );
    }

    final previousYear = await useCase(
      year: 2025,
      range: OverviewRange.year,
      today: DateTime(2026, 1, 10),
    );

    expect(previousYear.rangeStart, DateTime(2025, 1, 1));
    expect(previousYear.rangeEnd, DateTime(2025, 12, 31));
    expect(previousYear.totalLitDays, 2);
    expect(previousYear.totalValidDays, 12);
    expect(previousYear.overallCompletionRate, closeTo(1 / 6, 0.0001));
    expect(previousYear.habits.single.completedCountForYear, 2);
    expect(previousYear.habits.single.validDayCountForYear, 12);
    expect(previousYear.bestCurrentStreak, 0);
    expect(previousYear.bestLongestStreak, 4);

    final currentYear = await useCase(
      year: 2026,
      range: OverviewRange.year,
      today: DateTime(2026, 1, 10),
    );

    expect(currentYear.totalLitDays, 2);
    expect(currentYear.totalValidDays, 10);
    expect(currentYear.overallCompletionRate, closeTo(0.2, 0.0001));
    expect(currentYear.habits.single.completedCountForYear, 2);
    expect(currentYear.habits.single.validDayCountForYear, 10);
    expect(currentYear.dailyLitCounts.keys, <DateTime>[
      DateTime(2026, 1, 1),
      DateTime(2026, 1, 2),
    ]);

    final clippedWeek = await useCase(
      year: 2026,
      range: OverviewRange.week,
      today: DateTime(2026, 1, 2),
    );

    expect(clippedWeek.rangeStart, DateTime(2026, 1, 1));
    expect(clippedWeek.rangeEnd, DateTime(2026, 1, 2));
    expect(clippedWeek.totalLitDays, 2);
    expect(clippedWeek.totalValidDays, 2);
    expect(clippedWeek.overallCompletionRate, 1);

    final previousYearWeek = await useCase(
      year: 2025,
      range: OverviewRange.week,
      today: DateTime(2026, 1, 2),
    );

    expect(previousYearWeek.rangeStart, DateTime(2025, 12, 27));
    expect(previousYearWeek.rangeEnd, DateTime(2025, 12, 31));
    expect(previousYearWeek.totalLitDays, 2);
    expect(previousYearWeek.totalValidDays, 5);
    expect(previousYearWeek.overallCompletionRate, closeTo(0.4, 0.0001));
  });
}

StarNyx _habit({
  required String id,
  required String title,
  required DateTime startDate,
  String icon = 'star',
}) {
  return StarNyx(
    id: id,
    title: title,
    description: null,
    color: '#DE7B30',
    startDate: startDate,
    reminderEnabled: false,
    reminderTime: null,
    createdAt: startDate,
    updatedAt: startDate,
    icon: icon,
  );
}

class _InMemoryStarNyxRepository implements StarNyxRepository {
  final Map<String, StarNyx> _items = <String, StarNyx>{};

  @override
  Future<void> deleteStarnyxById(String id) async {
    _items.remove(id);
  }

  @override
  Future<List<StarNyx>> getAllStarnyxs() async {
    return _items.values.toList(growable: false);
  }

  @override
  Future<StarNyx?> getStarnyxById(String id) async => _items[id];

  @override
  Future<void> reorderStarnyxs(List<String> orderedIds) async {}

  @override
  Future<void> saveStarnyx(StarNyx starnyx) async {
    _items[starnyx.id] = starnyx;
  }

  @override
  Stream<List<StarNyx>> watchAllStarnyxs() {
    throw UnimplementedError();
  }
}

class _InMemoryCompletionRepository implements CompletionRepository {
  final Map<String, Completion> _items = <String, Completion>{};

  @override
  Future<void> deleteCompletionByDate({
    required String starnyxId,
    required DateTime date,
  }) async {
    _items.remove(_key(starnyxId, date));
  }

  @override
  Future<void> deleteCompletionsForStarnyx(String starnyxId) async {
    _items.removeWhere((key, value) => value.starnyxId == starnyxId);
  }

  @override
  Future<Completion?> getCompletionByDate({
    required String starnyxId,
    required DateTime date,
  }) async {
    return _items[_key(starnyxId, date)];
  }

  @override
  Future<List<Completion>> getCompletionsForStarnyx(String starnyxId) async {
    return _items.values
        .where((item) => item.starnyxId == starnyxId)
        .toList(growable: false);
  }

  @override
  Future<void> saveCompletion(Completion completion) async {
    _items[_key(completion.starnyxId, completion.date)] = completion;
  }

  @override
  Stream<List<Completion>> watchCompletionsForStarnyx(String starnyxId) {
    throw UnimplementedError();
  }
}

String _key(String starnyxId, DateTime date) {
  return '$starnyxId:${date.toIso8601String()}';
}

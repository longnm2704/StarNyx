import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/domain/entities/domain_entities.dart';
import 'package:starnyx/domain/repositories/domain_repositories.dart';
import 'package:starnyx/domain/usecases/load_starnyx_progress_stats_use_case.dart';

// Covers the main stats aggregation use case used by the future home screen.
void main() {
  test(
    'aggregates streak and completion rate metrics for one StarNyx',
    () async {
      final starnyxRepository = _InMemoryStarNyxRepository();
      final completionRepository = _InMemoryCompletionRepository();
      final starnyx = StarNyx(
        id: 'habit-1',
        title: 'Hydrate',
        description: null,
        color: '#102030',
        startDate: DateTime(2026, 4, 5),
        reminderEnabled: false,
        reminderTime: null,
        createdAt: DateTime(2026, 4, 5, 8),
        updatedAt: DateTime(2026, 4, 5, 8),
      );

      await starnyxRepository.saveStarnyx(starnyx);
      await completionRepository.saveCompletion(
        Completion(
          starnyxId: 'habit-1',
          date: DateTime(2026, 4, 7),
          completed: true,
        ),
      );
      await completionRepository.saveCompletion(
        Completion(
          starnyxId: 'habit-1',
          date: DateTime(2026, 4, 8),
          completed: true,
        ),
      );
      await completionRepository.saveCompletion(
        Completion(
          starnyxId: 'habit-1',
          date: DateTime(2026, 4, 9),
          completed: true,
        ),
      );

      final useCase = LoadStarNyxProgressStatsUseCase(
        starnyxRepository,
        completionRepository,
      );
      final stats = await useCase(
        starnyxId: 'habit-1',
        year: 2026,
        today: DateTime(2026, 4, 10),
      );

      expect(stats.currentStreak, 3);
      expect(stats.longestStreak, 3);
      expect(stats.totalCompletedCount, 3);
      expect(stats.completedCountForYear, 3);
      expect(stats.validDayCountForYear, 6);
      expect(stats.completionRateForYear, closeTo(0.5, 0.0001));
    },
  );

  test('throws when the requested StarNyx does not exist', () async {
    final useCase = LoadStarNyxProgressStatsUseCase(
      _InMemoryStarNyxRepository(),
      _InMemoryCompletionRepository(),
    );

    expect(
      () => useCase(
        starnyxId: 'missing',
        year: 2026,
        today: DateTime(2026, 4, 10),
      ),
      throwsA(isA<StateError>()),
    );
  });
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

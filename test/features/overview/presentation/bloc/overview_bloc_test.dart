import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/core/constants/enums.dart';
import 'package:starnyx/domain/entities/domain_entities.dart';
import 'package:starnyx/domain/repositories/domain_repositories.dart';
import 'package:starnyx/domain/usecases/load_overview_stats_use_case.dart';
import 'package:starnyx/domain/usecases/load_starnyx_progress_stats_use_case.dart';
import 'package:starnyx/domain/usecases/load_starnyxs_use_case.dart';
import 'package:starnyx/features/overview/presentation/bloc/overview_bloc.dart';
import 'package:starnyx/features/overview/presentation/bloc/overview_event.dart';
import 'package:starnyx/features/overview/presentation/bloc/overview_state.dart';

void main() {
  test('loads weekly stats and reloads when the range changes', () async {
    final starnyxRepository = _InMemoryStarNyxRepository();
    final completionRepository = _InMemoryCompletionRepository();
    await starnyxRepository.saveStarnyx(
      StarNyx(
        id: 'habit-1',
        title: 'Hydrate',
        description: null,
        color: '#DE7B30',
        startDate: DateTime(2026, 4, 1),
        reminderEnabled: false,
        reminderTime: null,
        createdAt: DateTime(2026, 4, 1, 8),
        updatedAt: DateTime(2026, 4, 1, 8),
      ),
    );
    for (final date in <DateTime>[
      DateTime(2026, 4, 10),
      DateTime(2026, 4, 18),
    ]) {
      await completionRepository.saveCompletion(
        Completion(starnyxId: 'habit-1', date: date, completed: true),
      );
    }

    final bloc = OverviewBloc(
      loadOverviewStatsUseCase: LoadOverviewStatsUseCase(
        LoadStarnyxsUseCase(starnyxRepository),
        completionRepository,
        LoadStarNyxProgressStatsUseCase(
          starnyxRepository,
          completionRepository,
        ),
      ),
      nowBuilder: () => DateTime(2026, 4, 19, 10, 30),
    );
    addTearDown(bloc.close);

    expect(bloc.state.year, 2026);
    expect(bloc.state.range, OverviewRange.week);
    expect(bloc.state.status, OverviewStatus.initial);

    final loadExpectation = expectLater(
      bloc.stream,
      emitsInOrder(<Matcher>[
        isA<OverviewState>().having(
          (OverviewState state) => state.status,
          'status',
          OverviewStatus.loading,
        ),
        isA<OverviewState>()
            .having(
              (OverviewState state) => state.status,
              'status',
              OverviewStatus.success,
            )
            .having(
              (OverviewState state) => state.range,
              'range',
              OverviewRange.week,
            )
            .having(
              (OverviewState state) => state.stats?.totalLitDays,
              'totalLitDays',
              1,
            )
            .having(
              (OverviewState state) => state.stats?.totalValidDays,
              'totalValidDays',
              7,
            )
            .having(
              (OverviewState state) => state.stats?.rangeStart,
              'rangeStart',
              DateTime(2026, 4, 13),
            ),
      ]),
    );
    bloc.add(const OverviewLoadRequested());
    await loadExpectation;

    final rangeExpectation = expectLater(
      bloc.stream,
      emitsInOrder(<Matcher>[
        isA<OverviewState>().having(
          (OverviewState state) => state.range,
          'range',
          OverviewRange.month,
        ),
        isA<OverviewState>()
            .having(
              (OverviewState state) => state.status,
              'status',
              OverviewStatus.success,
            )
            .having(
              (OverviewState state) => state.range,
              'range',
              OverviewRange.month,
            )
            .having(
              (OverviewState state) => state.stats?.totalLitDays,
              'totalLitDays',
              2,
            )
            .having(
              (OverviewState state) => state.stats?.totalValidDays,
              'totalValidDays',
              19,
            )
            .having(
              (OverviewState state) => state.stats?.rangeStart,
              'rangeStart',
              DateTime(2026, 4, 1),
            ),
      ]),
    );
    bloc.add(const OverviewRangeChanged(OverviewRange.month));
    await rangeExpectation;

    expect(bloc.state.range, OverviewRange.month);
    expect(bloc.state.year, 2026);
  });

  test('emits failure when stats cannot be loaded', () async {
    final failingRepository = _FailingStarNyxRepository();
    final completionRepository = _InMemoryCompletionRepository();
    final bloc = OverviewBloc(
      loadOverviewStatsUseCase: LoadOverviewStatsUseCase(
        LoadStarnyxsUseCase(failingRepository),
        completionRepository,
        LoadStarNyxProgressStatsUseCase(
          failingRepository,
          completionRepository,
        ),
      ),
      nowBuilder: () => DateTime(2026, 4, 19),
    );
    addTearDown(bloc.close);

    final expectation = expectLater(
      bloc.stream,
      emitsInOrder(<Matcher>[
        isA<OverviewState>().having(
          (OverviewState state) => state.status,
          'status',
          OverviewStatus.loading,
        ),
        isA<OverviewState>()
            .having(
              (OverviewState state) => state.status,
              'status',
              OverviewStatus.failure,
            )
            .having((OverviewState state) => state.stats, 'stats', isNull),
      ]),
    );
    bloc.add(const OverviewLoadRequested());
    await expectation;
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

class _FailingStarNyxRepository implements StarNyxRepository {
  @override
  Future<void> deleteStarnyxById(String id) async {}

  @override
  Future<List<StarNyx>> getAllStarnyxs() {
    throw StateError('database unavailable');
  }

  @override
  Future<StarNyx?> getStarnyxById(String id) async => null;

  @override
  Future<void> reorderStarnyxs(List<String> orderedIds) async {}

  @override
  Future<void> saveStarnyx(StarNyx starnyx) async {}

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

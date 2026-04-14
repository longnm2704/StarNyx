import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/entities/starnyx_progress_stats.dart';
import 'package:starnyx/domain/usecases/load_starnyxs_use_case.dart';
import 'package:starnyx/features/home/presentation/bloc/home_bloc.dart';
import 'package:starnyx/features/home/presentation/bloc/home_event.dart';
import 'package:starnyx/features/home/presentation/bloc/home_state.dart';
import 'package:starnyx/domain/usecases/load_active_starnyx_use_case.dart';
import 'package:starnyx/domain/usecases/load_starnyx_completion_dates_for_year_use_case.dart';
import 'package:starnyx/domain/usecases/load_starnyx_progress_stats_use_case.dart';
import 'package:starnyx/domain/usecases/select_active_starnyx_use_case.dart';
import 'package:starnyx/domain/usecases/toggle_completion_use_case.dart';
import 'package:starnyx/domain/usecases/use_case_validation.dart';

void main() {
  late _MockLoadStarnyxsUseCase loadStarnyxsUseCase;
  late _MockLoadActiveStarNyxUseCase loadActiveStarNyxUseCase;
  late _MockSelectActiveStarNyxUseCase selectActiveStarNyxUseCase;
  late _MockLoadStarNyxProgressStatsUseCase loadStarNyxProgressStatsUseCase;
  late _MockLoadStarNyxCompletionDatesForYearUseCase
  loadStarNyxCompletionDatesForYearUseCase;
  late _MockToggleCompletionUseCase toggleCompletionUseCase;

  setUpAll(() {
    registerFallbackValue(DateTime(2026, 4, 14));
  });

  setUp(() {
    loadStarnyxsUseCase = _MockLoadStarnyxsUseCase();
    loadActiveStarNyxUseCase = _MockLoadActiveStarNyxUseCase();
    selectActiveStarNyxUseCase = _MockSelectActiveStarNyxUseCase();
    loadStarNyxProgressStatsUseCase = _MockLoadStarNyxProgressStatsUseCase();
    loadStarNyxCompletionDatesForYearUseCase =
        _MockLoadStarNyxCompletionDatesForYearUseCase();
    toggleCompletionUseCase = _MockToggleCompletionUseCase();
  });

  test('load requested emits success with starnyxs and active id', () async {
    final starnyxs = <StarNyx>[_starnyx(id: '1', title: 'Hydrate')];
    when(() => loadStarnyxsUseCase()).thenAnswer((_) async => starnyxs);
    when(
      () => loadActiveStarNyxUseCase(now: any(named: 'now')),
    ).thenAnswer((_) async => starnyxs.first);
    when(
      () => loadStarNyxProgressStatsUseCase(
        starnyxId: '1',
        year: 2026,
        today: any(named: 'today'),
      ),
    ).thenAnswer((_) async => _stats());
    when(
      () => loadStarNyxCompletionDatesForYearUseCase(starnyxId: '1', year: 2026),
    ).thenAnswer((_) async => <DateTime>[DateTime(2026, 4, 13)]);
    final bloc = HomeBloc(
      loadStarnyxsUseCase: loadStarnyxsUseCase,
      loadActiveStarNyxUseCase: loadActiveStarNyxUseCase,
      selectActiveStarNyxUseCase: selectActiveStarNyxUseCase,
      loadStarNyxProgressStatsUseCase: loadStarNyxProgressStatsUseCase,
      loadStarNyxCompletionDatesForYearUseCase:
          loadStarNyxCompletionDatesForYearUseCase,
      toggleCompletionUseCase: toggleCompletionUseCase,
      nowBuilder: () => DateTime(2026, 4, 14),
    );

    bloc.add(const HomeLoadRequested());
    await pumpEventQueue(times: 10);

    expect(bloc.state.status, HomeStatus.success);
    expect(bloc.state.starnyxs, starnyxs);
    expect(bloc.state.activeStarnyxId, '1');
    expect(bloc.state.selectedDate, DateTime(2026, 4, 14));
    expect(bloc.state.viewedYear, 2026);
    expect(bloc.state.progressStats, _stats());
    expect(bloc.state.completedDatesForViewedYear, <DateTime>[
      DateTime(2026, 4, 13),
    ]);
  });

  test('load requested emits failure when loading throws', () async {
    when(() => loadStarnyxsUseCase()).thenThrow(Exception('db fail'));
    final bloc = HomeBloc(
      loadStarnyxsUseCase: loadStarnyxsUseCase,
      loadActiveStarNyxUseCase: loadActiveStarNyxUseCase,
      selectActiveStarNyxUseCase: selectActiveStarNyxUseCase,
      loadStarNyxProgressStatsUseCase: loadStarNyxProgressStatsUseCase,
      loadStarNyxCompletionDatesForYearUseCase:
          loadStarNyxCompletionDatesForYearUseCase,
      toggleCompletionUseCase: toggleCompletionUseCase,
      nowBuilder: () => DateTime(2026, 4, 14),
    );

    bloc.add(const HomeLoadRequested());
    await pumpEventQueue(times: 10);

    expect(bloc.state.status, HomeStatus.failure);
    expect(bloc.state.starnyxs, isEmpty);
  });

  test('select day, move previous/next day, and jump today update selection', () async {
    final starnyxs = <StarNyx>[_starnyx(id: '1', title: 'Hydrate')];
    when(() => loadStarnyxsUseCase()).thenAnswer((_) async => starnyxs);
    when(
      () => loadActiveStarNyxUseCase(now: any(named: 'now')),
    ).thenAnswer((_) async => starnyxs.first);
    when(
      () => loadStarNyxProgressStatsUseCase(
        starnyxId: '1',
        year: 2026,
        today: any(named: 'today'),
      ),
    ).thenAnswer((_) async => _stats());
    when(
      () => loadStarNyxCompletionDatesForYearUseCase(starnyxId: '1', year: 2026),
    ).thenAnswer((_) async => <DateTime>[DateTime(2026, 4, 13)]);
    final bloc = HomeBloc(
      loadStarnyxsUseCase: loadStarnyxsUseCase,
      loadActiveStarNyxUseCase: loadActiveStarNyxUseCase,
      selectActiveStarNyxUseCase: selectActiveStarNyxUseCase,
      loadStarNyxProgressStatsUseCase: loadStarNyxProgressStatsUseCase,
      loadStarNyxCompletionDatesForYearUseCase:
          loadStarNyxCompletionDatesForYearUseCase,
      toggleCompletionUseCase: toggleCompletionUseCase,
      nowBuilder: () => DateTime(2026, 4, 14),
    );

    bloc.add(const HomeLoadRequested());
    await pumpEventQueue(times: 10);

    bloc.add(HomeDaySelected(DateTime(2026, 4, 12, 23, 59)));
    await pumpEventQueue(times: 10);
    expect(bloc.state.selectedDate, DateTime(2026, 4, 12));

    bloc.add(const HomePreviousDayRequested());
    await pumpEventQueue(times: 10);
    expect(bloc.state.selectedDate, DateTime(2026, 4, 11));

    bloc.add(const HomeNextDayRequested());
    await pumpEventQueue(times: 10);
    expect(bloc.state.selectedDate, DateTime(2026, 4, 12));

    bloc.add(const HomeJumpToTodayRequested());
    await pumpEventQueue(times: 10);
    expect(bloc.state.selectedDate, DateTime(2026, 4, 14));
    expect(bloc.state.viewedYear, 2026);
  });

  test('change year updates viewed year and reloads year-scoped data', () async {
    final starnyxs = <StarNyx>[_starnyx(id: '1', title: 'Hydrate')];
    when(() => loadStarnyxsUseCase()).thenAnswer((_) async => starnyxs);
    when(
      () => loadActiveStarNyxUseCase(now: any(named: 'now')),
    ).thenAnswer((_) async => starnyxs.first);
    when(
      () => loadStarNyxProgressStatsUseCase(
        starnyxId: '1',
        year: 2026,
        today: any(named: 'today'),
      ),
    ).thenAnswer((_) async => _stats());
    when(
      () => loadStarNyxCompletionDatesForYearUseCase(starnyxId: '1', year: 2026),
    ).thenAnswer((_) async => <DateTime>[DateTime(2026, 4, 13)]);
    when(
      () => loadStarNyxProgressStatsUseCase(
        starnyxId: '1',
        year: 2025,
        today: any(named: 'today'),
      ),
    ).thenAnswer((_) async => _stats(currentStreak: 2));
    when(
      () => loadStarNyxCompletionDatesForYearUseCase(starnyxId: '1', year: 2025),
    ).thenAnswer((_) async => <DateTime>[DateTime(2025, 12, 31)]);
    final bloc = HomeBloc(
      loadStarnyxsUseCase: loadStarnyxsUseCase,
      loadActiveStarNyxUseCase: loadActiveStarNyxUseCase,
      selectActiveStarNyxUseCase: selectActiveStarNyxUseCase,
      loadStarNyxProgressStatsUseCase: loadStarNyxProgressStatsUseCase,
      loadStarNyxCompletionDatesForYearUseCase:
          loadStarNyxCompletionDatesForYearUseCase,
      toggleCompletionUseCase: toggleCompletionUseCase,
      nowBuilder: () => DateTime(2026, 4, 14),
    );

    bloc.add(const HomeLoadRequested());
    await pumpEventQueue(times: 10);

    bloc.add(const HomeYearChanged(2025));
    await pumpEventQueue(times: 10);

    expect(bloc.state.viewedYear, 2025);
    expect(bloc.state.selectedDate.year, 2025);
    expect(bloc.state.progressStats, _stats(currentStreak: 2));
    expect(bloc.state.completedDatesForViewedYear, <DateTime>[
      DateTime(2025, 12, 31),
    ]);
  });

  test('reload keeps selected day and viewed year instead of resetting to today', () async {
    final starnyxs = <StarNyx>[_starnyx(id: '1', title: 'Hydrate')];
    when(() => loadStarnyxsUseCase()).thenAnswer((_) async => starnyxs);
    when(
      () => loadActiveStarNyxUseCase(now: any(named: 'now')),
    ).thenAnswer((_) async => starnyxs.first);
    when(
      () => loadStarNyxProgressStatsUseCase(
        starnyxId: '1',
        year: 2026,
        today: any(named: 'today'),
      ),
    ).thenAnswer((_) async => _stats());
    when(
      () => loadStarNyxCompletionDatesForYearUseCase(starnyxId: '1', year: 2026),
    ).thenAnswer((_) async => <DateTime>[DateTime(2026, 4, 13)]);
    when(
      () => loadStarNyxProgressStatsUseCase(
        starnyxId: '1',
        year: 2025,
        today: any(named: 'today'),
      ),
    ).thenAnswer((_) async => _stats(currentStreak: 2));
    when(
      () => loadStarNyxCompletionDatesForYearUseCase(starnyxId: '1', year: 2025),
    ).thenAnswer((_) async => <DateTime>[DateTime(2025, 12, 31)]);
    final bloc = HomeBloc(
      loadStarnyxsUseCase: loadStarnyxsUseCase,
      loadActiveStarNyxUseCase: loadActiveStarNyxUseCase,
      selectActiveStarNyxUseCase: selectActiveStarNyxUseCase,
      loadStarNyxProgressStatsUseCase: loadStarNyxProgressStatsUseCase,
      loadStarNyxCompletionDatesForYearUseCase:
          loadStarNyxCompletionDatesForYearUseCase,
      toggleCompletionUseCase: toggleCompletionUseCase,
      nowBuilder: () => DateTime(2026, 4, 14),
    );

    bloc.add(const HomeLoadRequested());
    await pumpEventQueue(times: 10);

    bloc.add(HomeDaySelected(DateTime(2025, 12, 31)));
    await pumpEventQueue(times: 10);
    expect(bloc.state.selectedDate, DateTime(2025, 12, 31));
    expect(bloc.state.viewedYear, 2025);

    bloc.add(const HomeReloadRequested());
    await pumpEventQueue(times: 10);

    expect(bloc.state.selectedDate, DateTime(2025, 12, 31));
    expect(bloc.state.viewedYear, 2025);
    expect(bloc.state.progressStats, _stats(currentStreak: 2));
    expect(bloc.state.completedDatesForViewedYear, <DateTime>[
      DateTime(2025, 12, 31),
    ]);
  });

  test('latest year change wins when year requests complete out of order', () async {
    final starnyxs = <StarNyx>[_starnyx(id: '1', title: 'Hydrate')];
    final year2025Stats = Completer<StarNyxProgressStats>();
    final year2025Dates = Completer<List<DateTime>>();
    when(() => loadStarnyxsUseCase()).thenAnswer((_) async => starnyxs);
    when(
      () => loadActiveStarNyxUseCase(now: any(named: 'now')),
    ).thenAnswer((_) async => starnyxs.first);
    when(
      () => loadStarNyxProgressStatsUseCase(
        starnyxId: '1',
        year: 2026,
        today: any(named: 'today'),
      ),
    ).thenAnswer((_) async => _stats());
    when(
      () => loadStarNyxCompletionDatesForYearUseCase(starnyxId: '1', year: 2026),
    ).thenAnswer((_) async => <DateTime>[DateTime(2026, 4, 13)]);
    when(
      () => loadStarNyxProgressStatsUseCase(
        starnyxId: '1',
        year: 2025,
        today: any(named: 'today'),
      ),
    ).thenAnswer((_) => year2025Stats.future);
    when(
      () => loadStarNyxCompletionDatesForYearUseCase(starnyxId: '1', year: 2025),
    ).thenAnswer((_) => year2025Dates.future);
    when(
      () => loadStarNyxProgressStatsUseCase(
        starnyxId: '1',
        year: 2024,
        today: any(named: 'today'),
      ),
    ).thenAnswer((_) async => _stats(currentStreak: 4));
    when(
      () => loadStarNyxCompletionDatesForYearUseCase(starnyxId: '1', year: 2024),
    ).thenAnswer((_) async => <DateTime>[DateTime(2024, 12, 31)]);
    final bloc = HomeBloc(
      loadStarnyxsUseCase: loadStarnyxsUseCase,
      loadActiveStarNyxUseCase: loadActiveStarNyxUseCase,
      selectActiveStarNyxUseCase: selectActiveStarNyxUseCase,
      loadStarNyxProgressStatsUseCase: loadStarNyxProgressStatsUseCase,
      loadStarNyxCompletionDatesForYearUseCase:
          loadStarNyxCompletionDatesForYearUseCase,
      toggleCompletionUseCase: toggleCompletionUseCase,
      nowBuilder: () => DateTime(2026, 4, 14),
    );

    bloc.add(const HomeLoadRequested());
    await pumpEventQueue(times: 10);

    bloc.add(const HomeYearChanged(2025));
    bloc.add(const HomeYearChanged(2024));
    await pumpEventQueue(times: 10);

    year2025Stats.complete(_stats(currentStreak: 2));
    year2025Dates.complete(<DateTime>[DateTime(2025, 12, 31)]);
    await pumpEventQueue(times: 10);

    expect(bloc.state.viewedYear, 2024);
    expect(bloc.state.selectedDate.year, 2024);
    expect(bloc.state.progressStats, _stats(currentStreak: 4));
    expect(bloc.state.completedDatesForViewedYear, <DateTime>[
      DateTime(2024, 12, 31),
    ]);
  });

  test('select requested persists active starnyx and reloads data', () async {
    final before = <StarNyx>[
      _starnyx(id: '1', title: 'Hydrate'),
      _starnyx(id: '2', title: 'Stretch'),
    ];
    final after = <StarNyx>[
      _starnyx(id: '1', title: 'Hydrate'),
      _starnyx(id: '2', title: 'Stretch'),
    ];
    when(() => loadStarnyxsUseCase()).thenAnswer((_) async => before);
    when(
      () => loadActiveStarNyxUseCase(now: any(named: 'now')),
    ).thenAnswer((_) async => before.first);
    when(
      () => loadStarNyxProgressStatsUseCase(
        starnyxId: '1',
        year: 2026,
        today: any(named: 'today'),
      ),
    ).thenAnswer((_) async => _stats());
    when(
      () => loadStarNyxCompletionDatesForYearUseCase(starnyxId: '1', year: 2026),
    ).thenAnswer((_) async => <DateTime>[DateTime(2026, 4, 13)]);
    when(
      () => selectActiveStarNyxUseCase('2', now: any(named: 'now')),
    ).thenAnswer((_) async {});
    final bloc = HomeBloc(
      loadStarnyxsUseCase: loadStarnyxsUseCase,
      loadActiveStarNyxUseCase: loadActiveStarNyxUseCase,
      selectActiveStarNyxUseCase: selectActiveStarNyxUseCase,
      loadStarNyxProgressStatsUseCase: loadStarNyxProgressStatsUseCase,
      loadStarNyxCompletionDatesForYearUseCase:
          loadStarNyxCompletionDatesForYearUseCase,
      toggleCompletionUseCase: toggleCompletionUseCase,
      nowBuilder: () => DateTime(2026, 4, 14),
    );

    bloc.add(const HomeLoadRequested());
    await pumpEventQueue(times: 10);

    when(() => loadStarnyxsUseCase()).thenAnswer((_) async => after);
    when(
      () => loadActiveStarNyxUseCase(now: any(named: 'now')),
    ).thenAnswer((_) async => after[1]);
    when(
      () => loadStarNyxProgressStatsUseCase(
        starnyxId: '2',
        year: 2026,
        today: any(named: 'today'),
      ),
    ).thenAnswer((_) async => _stats(currentStreak: 5));
    when(
      () => loadStarNyxCompletionDatesForYearUseCase(starnyxId: '2', year: 2026),
    ).thenAnswer((_) async => <DateTime>[DateTime(2026, 4, 14)]);

    bloc.add(const HomeActiveStarnyxSelected('2'));
    await pumpEventQueue(times: 10);

    expect(bloc.state.status, HomeStatus.success);
    expect(bloc.state.activeStarnyxId, '2');
    expect(bloc.state.selectionStatus, HomeSelectionStatus.success);
    expect(bloc.state.selectionFeedbackCount, 1);
    expect(bloc.state.progressStats, _stats(currentStreak: 5));
    verify(
      () => selectActiveStarNyxUseCase('2', now: any(named: 'now')),
    ).called(1);
  });

  test('select requested emits selection failure and keeps data', () async {
    final starnyxs = <StarNyx>[
      _starnyx(id: '1', title: 'Hydrate'),
      _starnyx(id: '2', title: 'Stretch'),
    ];
    when(() => loadStarnyxsUseCase()).thenAnswer((_) async => starnyxs);
    when(
      () => loadActiveStarNyxUseCase(now: any(named: 'now')),
    ).thenAnswer((_) async => starnyxs.first);
    when(
      () => loadStarNyxProgressStatsUseCase(
        starnyxId: '1',
        year: 2026,
        today: any(named: 'today'),
      ),
    ).thenAnswer((_) async => _stats());
    when(
      () => loadStarNyxCompletionDatesForYearUseCase(starnyxId: '1', year: 2026),
    ).thenAnswer((_) async => <DateTime>[DateTime(2026, 4, 13)]);
    when(
      () => selectActiveStarNyxUseCase('2', now: any(named: 'now')),
    ).thenThrow(StateError('missing'));
    final bloc = HomeBloc(
      loadStarnyxsUseCase: loadStarnyxsUseCase,
      loadActiveStarNyxUseCase: loadActiveStarNyxUseCase,
      selectActiveStarNyxUseCase: selectActiveStarNyxUseCase,
      loadStarNyxProgressStatsUseCase: loadStarNyxProgressStatsUseCase,
      loadStarNyxCompletionDatesForYearUseCase:
          loadStarNyxCompletionDatesForYearUseCase,
      toggleCompletionUseCase: toggleCompletionUseCase,
      nowBuilder: () => DateTime(2026, 4, 14),
    );

    bloc.add(const HomeLoadRequested());
    await pumpEventQueue(times: 10);

    bloc.add(const HomeActiveStarnyxSelected('2'));
    await pumpEventQueue(times: 10);

    expect(bloc.state.status, HomeStatus.success);
    expect(bloc.state.activeStarnyxId, '1');
    expect(bloc.state.selectionStatus, HomeSelectionStatus.failure);
    expect(bloc.state.selectionFeedbackCount, 1);
  });

  test('toggle completion refreshes state and emits success feedback', () async {
    final starnyxs = <StarNyx>[_starnyx(id: '1', title: 'Hydrate')];
    when(() => loadStarnyxsUseCase()).thenAnswer((_) async => starnyxs);
    when(
      () => loadActiveStarNyxUseCase(now: any(named: 'now')),
    ).thenAnswer((_) async => starnyxs.first);
    when(
      () => loadStarNyxProgressStatsUseCase(
        starnyxId: '1',
        year: 2026,
        today: any(named: 'today'),
      ),
    ).thenAnswer((_) async => _stats());
    when(
      () => loadStarNyxCompletionDatesForYearUseCase(starnyxId: '1', year: 2026),
    ).thenAnswer((_) async => <DateTime>[DateTime(2026, 4, 13)]);
    when(
      () => toggleCompletionUseCase(
        starnyxId: '1',
        date: DateTime(2026, 4, 14),
        today: any(named: 'today'),
      ),
    ).thenAnswer((_) async => true);
    when(
      () => loadStarNyxProgressStatsUseCase(
        starnyxId: '1',
        year: 2026,
        today: any(named: 'today'),
      ),
    ).thenAnswer((_) async => _stats(currentStreak: 7));
    when(
      () => loadStarNyxCompletionDatesForYearUseCase(starnyxId: '1', year: 2026),
    ).thenAnswer((_) async => <DateTime>[DateTime(2026, 4, 14)]);
    final bloc = HomeBloc(
      loadStarnyxsUseCase: loadStarnyxsUseCase,
      loadActiveStarNyxUseCase: loadActiveStarNyxUseCase,
      selectActiveStarNyxUseCase: selectActiveStarNyxUseCase,
      loadStarNyxProgressStatsUseCase: loadStarNyxProgressStatsUseCase,
      loadStarNyxCompletionDatesForYearUseCase:
          loadStarNyxCompletionDatesForYearUseCase,
      toggleCompletionUseCase: toggleCompletionUseCase,
      nowBuilder: () => DateTime(2026, 4, 14),
    );

    bloc.add(const HomeLoadRequested());
    await pumpEventQueue(times: 10);

    bloc.add(const HomeCompletionToggled());
    await pumpEventQueue(times: 10);

    expect(bloc.state.completionStatus, HomeCompletionStatus.success);
    expect(bloc.state.completionFeedbackCount, 1);
    expect(bloc.state.progressStats, _stats(currentStreak: 7));
    expect(bloc.state.completedDatesForViewedYear, <DateTime>[
      DateTime(2026, 4, 14),
    ]);
  });

  test('toggle completion emits failure feedback on 7-day lock', () async {
    final starnyxs = <StarNyx>[_starnyx(id: '1', title: 'Hydrate')];
    when(() => loadStarnyxsUseCase()).thenAnswer((_) async => starnyxs);
    when(
      () => loadActiveStarNyxUseCase(now: any(named: 'now')),
    ).thenAnswer((_) async => starnyxs.first);
    when(
      () => loadStarNyxProgressStatsUseCase(
        starnyxId: '1',
        year: 2026,
        today: any(named: 'today'),
      ),
    ).thenAnswer((_) async => _stats());
    when(
      () => loadStarNyxCompletionDatesForYearUseCase(starnyxId: '1', year: 2026),
    ).thenAnswer((_) async => <DateTime>[DateTime(2026, 4, 13)]);
    when(
      () => toggleCompletionUseCase(
        starnyxId: '1',
        date: DateTime(2026, 4, 14),
        today: any(named: 'today'),
      ),
    ).thenThrow(
      const UseCaseValidationException(
        code: UseCaseValidationCode.completionEditWindowExpired,
        message: 'Completion can only be edited within the last 7 days.',
      ),
    );
    final bloc = HomeBloc(
      loadStarnyxsUseCase: loadStarnyxsUseCase,
      loadActiveStarNyxUseCase: loadActiveStarNyxUseCase,
      selectActiveStarNyxUseCase: selectActiveStarNyxUseCase,
      loadStarNyxProgressStatsUseCase: loadStarNyxProgressStatsUseCase,
      loadStarNyxCompletionDatesForYearUseCase:
          loadStarNyxCompletionDatesForYearUseCase,
      toggleCompletionUseCase: toggleCompletionUseCase,
      nowBuilder: () => DateTime(2026, 4, 14),
    );

    bloc.add(const HomeLoadRequested());
    await pumpEventQueue(times: 10);

    bloc.add(const HomeCompletionToggled());
    await pumpEventQueue(times: 10);

    expect(bloc.state.completionStatus, HomeCompletionStatus.failure);
    expect(bloc.state.completionFeedbackCount, 1);
    expect(bloc.state.progressStats, _stats());
  });
}

StarNyx _starnyx({required String id, required String title}) {
  return StarNyx(
    id: id,
    title: title,
    description: null,
    color: '#2360E9',
    startDate: DateTime(2026, 4, 10),
    reminderEnabled: false,
    reminderTime: null,
    createdAt: DateTime(2026, 4, 10, 8),
    updatedAt: DateTime(2026, 4, 10, 8),
  );
}

class _MockLoadStarnyxsUseCase extends Mock implements LoadStarnyxsUseCase {}

class _MockLoadActiveStarNyxUseCase extends Mock
    implements LoadActiveStarNyxUseCase {}

class _MockSelectActiveStarNyxUseCase extends Mock
    implements SelectActiveStarNyxUseCase {}

class _MockLoadStarNyxProgressStatsUseCase extends Mock
    implements LoadStarNyxProgressStatsUseCase {}

class _MockLoadStarNyxCompletionDatesForYearUseCase extends Mock
    implements LoadStarNyxCompletionDatesForYearUseCase {}

class _MockToggleCompletionUseCase extends Mock
    implements ToggleCompletionUseCase {}

StarNyxProgressStats _stats({int currentStreak = 6}) {
  return StarNyxProgressStats(
    currentStreak: currentStreak,
    longestStreak: 12,
    totalCompletedCount: 50,
    completedCountForYear: 20,
    validDayCountForYear: 100,
    completionRateForYear: 0.2,
  );
}

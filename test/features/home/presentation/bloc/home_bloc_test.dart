import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/usecases/load_starnyxs_use_case.dart';
import 'package:starnyx/features/home/presentation/bloc/home_bloc.dart';
import 'package:starnyx/features/home/presentation/bloc/home_event.dart';
import 'package:starnyx/features/home/presentation/bloc/home_state.dart';
import 'package:starnyx/domain/usecases/load_active_starnyx_use_case.dart';
import 'package:starnyx/domain/usecases/select_active_starnyx_use_case.dart';

void main() {
  late _MockLoadStarnyxsUseCase loadStarnyxsUseCase;
  late _MockLoadActiveStarNyxUseCase loadActiveStarNyxUseCase;
  late _MockSelectActiveStarNyxUseCase selectActiveStarNyxUseCase;

  setUpAll(() {
    registerFallbackValue(DateTime(2026, 4, 14));
  });

  setUp(() {
    loadStarnyxsUseCase = _MockLoadStarnyxsUseCase();
    loadActiveStarNyxUseCase = _MockLoadActiveStarNyxUseCase();
    selectActiveStarNyxUseCase = _MockSelectActiveStarNyxUseCase();
  });

  test('load requested emits success with starnyxs and active id', () async {
    final starnyxs = <StarNyx>[_starnyx(id: '1', title: 'Hydrate')];
    when(() => loadStarnyxsUseCase()).thenAnswer((_) async => starnyxs);
    when(
      () => loadActiveStarNyxUseCase(now: any(named: 'now')),
    ).thenAnswer((_) async => starnyxs.first);
    final bloc = HomeBloc(
      loadStarnyxsUseCase: loadStarnyxsUseCase,
      loadActiveStarNyxUseCase: loadActiveStarNyxUseCase,
      selectActiveStarNyxUseCase: selectActiveStarNyxUseCase,
      nowBuilder: () => DateTime(2026, 4, 14),
    );

    bloc.add(const HomeLoadRequested());
    await pumpEventQueue(times: 10);

    expect(bloc.state.status, HomeStatus.success);
    expect(bloc.state.starnyxs, starnyxs);
    expect(bloc.state.activeStarnyxId, '1');
  });

  test('load requested emits failure when loading throws', () async {
    when(() => loadStarnyxsUseCase()).thenThrow(Exception('db fail'));
    final bloc = HomeBloc(
      loadStarnyxsUseCase: loadStarnyxsUseCase,
      loadActiveStarNyxUseCase: loadActiveStarNyxUseCase,
      selectActiveStarNyxUseCase: selectActiveStarNyxUseCase,
      nowBuilder: () => DateTime(2026, 4, 14),
    );

    bloc.add(const HomeLoadRequested());
    await pumpEventQueue(times: 10);

    expect(bloc.state.status, HomeStatus.failure);
    expect(bloc.state.starnyxs, isEmpty);
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
      () => selectActiveStarNyxUseCase('2', now: any(named: 'now')),
    ).thenAnswer((_) async {});
    final bloc = HomeBloc(
      loadStarnyxsUseCase: loadStarnyxsUseCase,
      loadActiveStarNyxUseCase: loadActiveStarNyxUseCase,
      selectActiveStarNyxUseCase: selectActiveStarNyxUseCase,
      nowBuilder: () => DateTime(2026, 4, 14),
    );

    bloc.add(const HomeLoadRequested());
    await pumpEventQueue(times: 10);

    when(() => loadStarnyxsUseCase()).thenAnswer((_) async => after);
    when(
      () => loadActiveStarNyxUseCase(now: any(named: 'now')),
    ).thenAnswer((_) async => after[1]);

    bloc.add(const HomeActiveStarnyxSelected('2'));
    await pumpEventQueue(times: 10);

    expect(bloc.state.status, HomeStatus.success);
    expect(bloc.state.activeStarnyxId, '2');
    expect(bloc.state.selectionStatus, HomeSelectionStatus.success);
    expect(bloc.state.selectionFeedbackCount, 1);
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
      () => selectActiveStarNyxUseCase('2', now: any(named: 'now')),
    ).thenThrow(StateError('missing'));
    final bloc = HomeBloc(
      loadStarnyxsUseCase: loadStarnyxsUseCase,
      loadActiveStarNyxUseCase: loadActiveStarNyxUseCase,
      selectActiveStarNyxUseCase: selectActiveStarNyxUseCase,
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

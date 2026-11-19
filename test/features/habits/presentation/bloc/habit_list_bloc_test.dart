import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starnyx/core/constants/enums.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/repositories/starnyx_repository.dart';
import 'package:starnyx/domain/usecases/count_habits_completed_on_date_use_case.dart';
import 'package:starnyx/domain/usecases/load_active_starnyx_use_case.dart';
import 'package:starnyx/domain/usecases/load_starnyxs_use_case.dart';
import 'package:starnyx/domain/usecases/save_starnyx_order_use_case.dart';
import 'package:starnyx/domain/usecases/select_active_starnyx_use_case.dart';
import 'package:starnyx/features/habits/presentation/bloc/habit_list_bloc.dart';
import 'package:starnyx/features/habits/presentation/bloc/habit_list_event.dart';
import 'package:starnyx/features/habits/presentation/bloc/habit_list_state.dart';

class _MockLoad extends Mock implements LoadStarnyxsUseCase {}

class _MockLoadActive extends Mock implements LoadActiveStarNyxUseCase {}

class _MockSelect extends Mock implements SelectActiveStarNyxUseCase {}

class _MockSaveOrder extends Mock implements SaveStarNyxOrderUseCase {}

class _MockCount extends Mock implements CountHabitsCompletedOnDateUseCase {}

class _MockRepository extends Mock implements StarNyxRepository {}

StarNyx _habit(String id) => StarNyx(
  id: id,
  title: 'Habit $id',
  description: null,
  color: '#10B981',
  startDate: DateTime(2026, 4, 1),
  reminderEnabled: false,
  reminderTime: null,
  createdAt: DateTime(2026, 4, 1),
  updatedAt: DateTime(2026, 4, 1),
);

void main() {
  late _MockLoad load;
  late _MockLoadActive loadActive;
  late _MockSelect select;
  late _MockSaveOrder saveOrder;
  late _MockCount count;
  late HabitListBloc bloc;

  setUp(() {
    load = _MockLoad();
    loadActive = _MockLoadActive();
    select = _MockSelect();
    saveOrder = _MockSaveOrder();
    count = _MockCount();
    when(() => load()).thenAnswer((_) async => [_habit('1'), _habit('2')]);
    when(
      () => loadActive(now: any(named: 'now')),
    ).thenAnswer((_) async => _habit('1'));
    when(
      () => count(
        starnyxIds: any(named: 'starnyxIds'),
        date: any(named: 'date'),
      ),
    ).thenAnswer((_) async => 1);
    bloc = HabitListBloc(
      loadStarnyxsUseCase: load,
      loadActiveStarNyxUseCase: loadActive,
      selectActiveStarNyxUseCase: select,
      saveStarNyxOrderUseCase: saveOrder,
      countHabitsCompletedOnDateUseCase: count,
      nowBuilder: () => DateTime(2026, 4, 19, 10),
    );
  });

  tearDown(() => bloc.close());

  Future<HabitListState> settle() async {
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    return bloc.state;
  }

  test('load success exposes habits, active id and completed count', () async {
    bloc.add(const HabitListLoadRequested());
    final state = await settle();

    expect(state.status, HabitListStatus.success);
    expect(state.habits.map((h) => h.id), <String>['1', '2']);
    expect(state.activeHabitId, '1');
    expect(state.completedTodayCount, 1);
  });

  test('load success with no habits is an empty success', () async {
    when(() => load()).thenAnswer((_) async => <StarNyx>[]);
    when(() => loadActive(now: any(named: 'now'))).thenAnswer((_) async => null);
    bloc.add(const HabitListLoadRequested());
    final state = await settle();

    expect(state.status, HabitListStatus.success);
    expect(state.habits, isEmpty);
    expect(state.activeHabitId, isNull);
  });

  test('load failure emits failure with no habits', () async {
    when(() => load()).thenThrow(StateError('db'));
    bloc.add(const HabitListLoadRequested());
    final state = await settle();

    expect(state.status, HabitListStatus.failure);
    expect(state.habits, isEmpty);
  });

  test('selecting a habit stores it; failure keeps the old one', () async {
    when(() => select('2', now: any(named: 'now'))).thenAnswer((_) async {});
    bloc.add(const HabitListLoadRequested());
    await settle();

    bloc.add(const HabitListHabitSelected('2'));
    var state = await settle();
    expect(state.activeHabitId, '2');
    expect(state.selectionStatus, AsyncStatus.success);

    when(
      () => select('1', now: any(named: 'now')),
    ).thenThrow(StateError('db'));
    bloc.add(const HabitListHabitSelected('1'));
    state = await settle();
    expect(state.activeHabitId, '2');
    expect(state.selectionStatus, AsyncStatus.failure);
  });

  test('reorder applies the new order and reports save failures', () async {
    when(() => saveOrder(<String>['2', '1'])).thenAnswer((_) async {});
    bloc.add(const HabitListLoadRequested());
    await settle();

    bloc.add(const HabitListOrderChanged(<String>['2', '1']));
    var state = await settle();
    expect(state.habits.map((h) => h.id), <String>['2', '1']);
    expect(state.orderStatus, AsyncStatus.success);

    when(() => saveOrder(any())).thenThrow(StateError('db'));
    bloc.add(const HabitListOrderChanged(<String>['1', '2']));
    state = await settle();
    expect(state.orderStatus, AsyncStatus.failure);
  });

  test('SaveStarNyxOrderUseCase persists the order via the repository', () async {
    final repository = _MockRepository();
    when(() => repository.reorderStarnyxs(any())).thenAnswer((_) async {});

    await SaveStarNyxOrderUseCase(repository)(<String>['b', 'a']);

    verify(() => repository.reorderStarnyxs(<String>['b', 'a'])).called(1);
  });
}

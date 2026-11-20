import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starnyx/core/constants/enums.dart';
import 'package:starnyx/core/services/app_log_service.dart';
import 'package:starnyx/core/utils/date_utils.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/usecases/count_habits_completed_on_date_use_case.dart';
import 'package:starnyx/domain/usecases/load_active_starnyx_use_case.dart';
import 'package:starnyx/domain/usecases/load_starnyxs_use_case.dart';
import 'package:starnyx/domain/usecases/save_starnyx_order_use_case.dart';
import 'package:starnyx/domain/usecases/select_active_starnyx_use_case.dart';

import 'habit_list_event.dart';
import 'habit_list_state.dart';

/// Owns the full-screen habit list: loading, switching the active habit, and
/// persisting a new display order.
class HabitListBloc extends Bloc<HabitListEvent, HabitListState> {
  HabitListBloc({
    required LoadStarnyxsUseCase loadStarnyxsUseCase,
    required LoadActiveStarNyxUseCase loadActiveStarNyxUseCase,
    required SelectActiveStarNyxUseCase selectActiveStarNyxUseCase,
    required SaveStarNyxOrderUseCase saveStarNyxOrderUseCase,
    required CountHabitsCompletedOnDateUseCase
    countHabitsCompletedOnDateUseCase,
    AppLogService logger = const NoOpAppLogService(),
    DateTime Function()? nowBuilder,
  }) : _loadStarnyxsUseCase = loadStarnyxsUseCase,
       _loadActiveStarNyxUseCase = loadActiveStarNyxUseCase,
       _selectActiveStarNyxUseCase = selectActiveStarNyxUseCase,
       _saveStarNyxOrderUseCase = saveStarNyxOrderUseCase,
       _countHabitsCompletedOnDateUseCase = countHabitsCompletedOnDateUseCase,
       _logger = logger,
       _nowBuilder = nowBuilder ?? DateTime.now,
       super(const HabitListState()) {
    on<HabitListLoadRequested>(_onLoadRequested);
    on<HabitListReloadRequested>(_onLoadRequested);
    on<HabitListHabitSelected>(_onHabitSelected);
    on<HabitListOrderChanged>(_onOrderChanged);
  }

  final LoadStarnyxsUseCase _loadStarnyxsUseCase;
  final LoadActiveStarNyxUseCase _loadActiveStarNyxUseCase;
  final SelectActiveStarNyxUseCase _selectActiveStarNyxUseCase;
  final SaveStarNyxOrderUseCase _saveStarNyxOrderUseCase;
  final CountHabitsCompletedOnDateUseCase _countHabitsCompletedOnDateUseCase;
  final AppLogService _logger;
  final DateTime Function() _nowBuilder;

  Future<void> _onLoadRequested(
    HabitListEvent event,
    Emitter<HabitListState> emit,
  ) async {
    emit(state.copyWith(status: HabitListStatus.loading));
    final today = DateUtils.nowDate(_nowBuilder());

    try {
      final habits = await _loadStarnyxsUseCase();
      final active = await _loadActiveStarNyxUseCase(now: today);
      final completedTodayCount = await _countHabitsCompletedOnDateUseCase(
        starnyxIds: habits.map((habit) => habit.id).toList(growable: false),
        date: today,
      );
      if (emit.isDone) {
        return;
      }
      emit(
        state.copyWith(
          status: HabitListStatus.success,
          habits: habits,
          activeHabitId: active?.id,
          completedTodayCount: completedTodayCount,
          selectionStatus: AsyncStatus.idle,
          orderStatus: AsyncStatus.idle,
        ),
      );
    } catch (error, stackTrace) {
      if (emit.isDone) {
        return;
      }
      _logger.error(
        'HabitListBloc',
        'load failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          status: HabitListStatus.failure,
          habits: const <StarNyx>[],
          activeHabitId: null,
          completedTodayCount: 0,
        ),
      );
    }
  }

  Future<void> _onHabitSelected(
    HabitListHabitSelected event,
    Emitter<HabitListState> emit,
  ) async {
    // A double tap must not select (and pop) twice.
    if (state.selectionStatus == AsyncStatus.inProgress) return;
    if (event.id == state.activeHabitId) {
      emit(
        state.copyWith(
          selectionStatus: AsyncStatus.success,
          selectionFeedbackCount: state.selectionFeedbackCount + 1,
        ),
      );
      return;
    }

    emit(state.copyWith(selectionStatus: AsyncStatus.inProgress));

    try {
      await _selectActiveStarNyxUseCase(
        event.id,
        now: DateUtils.nowDate(_nowBuilder()),
      );
      if (emit.isDone) {
        return;
      }
      emit(
        state.copyWith(
          activeHabitId: event.id,
          selectionStatus: AsyncStatus.success,
          selectionFeedbackCount: state.selectionFeedbackCount + 1,
        ),
      );
    } catch (error, stackTrace) {
      if (emit.isDone) {
        return;
      }
      _logger.error(
        'HabitListBloc',
        'select failed id=${event.id}',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          selectionStatus: AsyncStatus.failure,
          selectionFeedbackCount: state.selectionFeedbackCount + 1,
        ),
      );
    }
  }

  Future<void> _onOrderChanged(
    HabitListOrderChanged event,
    Emitter<HabitListState> emit,
  ) async {
    final habitsById = <String, StarNyx>{
      for (final habit in state.habits) habit.id: habit,
    };
    final reordered = <StarNyx>[
      for (final id in event.orderedIds)
        if (habitsById[id] != null) habitsById[id]!,
    ];

    emit(
      state.copyWith(habits: reordered, orderStatus: AsyncStatus.inProgress),
    );

    try {
      await _saveStarNyxOrderUseCase(event.orderedIds);
      if (emit.isDone) {
        return;
      }
      emit(
        state.copyWith(
          orderStatus: AsyncStatus.success,
          orderFeedbackCount: state.orderFeedbackCount + 1,
        ),
      );
    } catch (error, stackTrace) {
      if (emit.isDone) {
        return;
      }
      _logger.error(
        'HabitListBloc',
        'save order failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          orderStatus: AsyncStatus.failure,
          orderFeedbackCount: state.orderFeedbackCount + 1,
        ),
      );
    }
  }
}

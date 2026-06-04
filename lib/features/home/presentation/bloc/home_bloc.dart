import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starnyx/core/utils/date_utils.dart';
import 'package:starnyx/core/services/core_services.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/entities/starnyx_progress_stats.dart';
import 'package:starnyx/domain/usecases/load_starnyxs_use_case.dart';
import 'package:starnyx/domain/usecases/save_starnyx_order_use_case.dart';
import 'package:starnyx/domain/usecases/toggle_completion_use_case.dart';
import 'package:starnyx/features/home/presentation/bloc/home_event.dart';
import 'package:starnyx/features/home/presentation/bloc/home_state.dart';
import 'package:starnyx/domain/usecases/load_active_starnyx_use_case.dart';
import 'package:starnyx/domain/usecases/select_active_starnyx_use_case.dart';
import 'package:starnyx/domain/usecases/load_starnyx_progress_stats_use_case.dart';
import 'package:starnyx/domain/usecases/load_starnyx_completion_dates_for_year_use_case.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required LoadStarnyxsUseCase loadStarnyxsUseCase,
    required LoadActiveStarNyxUseCase loadActiveStarNyxUseCase,
    required SelectActiveStarNyxUseCase selectActiveStarNyxUseCase,
    required LoadStarNyxProgressStatsUseCase loadStarNyxProgressStatsUseCase,
    required LoadStarNyxCompletionDatesForYearUseCase
    loadStarNyxCompletionDatesForYearUseCase,
    required ToggleCompletionUseCase toggleCompletionUseCase,
    SaveStarNyxOrderUseCase? saveStarNyxOrderUseCase,
    AppLogService logger = const NoOpAppLogService(),
    DateTime Function()? nowBuilder,
  }) : _loadStarnyxsUseCase = loadStarnyxsUseCase,
       _loadActiveStarNyxUseCase = loadActiveStarNyxUseCase,
       _selectActiveStarNyxUseCase = selectActiveStarNyxUseCase,
       _loadStarNyxProgressStatsUseCase = loadStarNyxProgressStatsUseCase,
       _loadStarNyxCompletionDatesForYearUseCase =
           loadStarNyxCompletionDatesForYearUseCase,
       _toggleCompletionUseCase = toggleCompletionUseCase,
       _saveStarNyxOrderUseCase = saveStarNyxOrderUseCase,
       _logger = logger,
       _nowBuilder = nowBuilder ?? DateTime.now,
       super(HomeState.initial()) {
    on<HomeLoadRequested>(_onLoadRequested);
    on<HomeReloadRequested>(_onLoadRequested);
    on<HomeActiveStarnyxSelected>(_onActiveStarnyxSelected);
    on<HomeDaySelected>(_onDaySelected);
    on<HomePreviousDayRequested>(_onPreviousDayRequested);
    on<HomeNextDayRequested>(_onNextDayRequested);
    on<HomeJumpToTodayRequested>(_onJumpToTodayRequested);
    on<HomeYearChanged>(_onYearChanged);
    on<HomeCompletionToggled>(_onCompletionToggled);
    on<HomeStarNyxOrderChanged>(_onStarNyxOrderChanged);
  }

  final LoadStarnyxsUseCase _loadStarnyxsUseCase;
  final LoadActiveStarNyxUseCase _loadActiveStarNyxUseCase;
  final SelectActiveStarNyxUseCase _selectActiveStarNyxUseCase;
  final LoadStarNyxProgressStatsUseCase _loadStarNyxProgressStatsUseCase;
  final LoadStarNyxCompletionDatesForYearUseCase
  _loadStarNyxCompletionDatesForYearUseCase;
  final ToggleCompletionUseCase _toggleCompletionUseCase;
  final SaveStarNyxOrderUseCase? _saveStarNyxOrderUseCase;
  final AppLogService _logger;
  final DateTime Function() _nowBuilder;
  int _latestDataRequestId = 0;

  Future<void> _onLoadRequested(
    HomeEvent event,
    Emitter<HomeState> emit,
  ) async {
    final today = DateUtils.nowDate(_nowBuilder());
    final context = _resolveLoadContext(event: event, today: today);
    final requestId = _nextDataRequestId();
    _logger.debug(
      'HomeBloc',
      'load begin event=${event.runtimeType} requestId=$requestId '
          'selectedDate=${context.selectedDate} viewedYear=${context.viewedYear}',
    );
    emit(
      state.copyWith(
        status: HomeStatus.loading,
        selectionStatus: AsyncStatus.idle,
        completionStatus: AsyncStatus.idle,
        selectedDate: context.selectedDate,
        viewedYear: context.viewedYear,
      ),
    );

    try {
      final starnyxs = await _loadStarnyxsUseCase();
      final activeStarnyx = await _loadActiveStarNyxUseCase(now: today);
      if (!_isLatestDataRequest(requestId) || emit.isDone) {
        _logger.debug('HomeBloc', 'load ignored stale requestId=$requestId');
        return;
      }
      emit(
        state.copyWith(
          status: HomeStatus.loading,
          starnyxs: starnyxs,
          activeStarnyxId: activeStarnyx?.id,
        ),
      );

      final data = await _loadHomeDataForActiveStarnyx(
        starnyxs: starnyxs,
        activeStarnyx: activeStarnyx,
        viewedYear: context.viewedYear,
        today: today,
      );
      if (!_isLatestDataRequest(requestId) || emit.isDone) {
        _logger.debug('HomeBloc', 'load ignored stale requestId=$requestId');
        return;
      }
      _logger.debug(
        'HomeBloc',
        'load success requestId=$requestId starnyxs=${data.starnyxs.length} '
            'activeId=${data.activeStarnyx?.id}',
      );
      emit(
        state.copyWith(
          status: HomeStatus.success,
          selectionStatus: AsyncStatus.idle,
          completionStatus: AsyncStatus.idle,
          starnyxs: data.starnyxs,
          activeStarnyxId: data.activeStarnyx?.id,
          selectedDate: context.selectedDate,
          viewedYear: context.viewedYear,
          progressStats: data.progressStats,
          completedDatesForViewedYear: data.completedDatesForViewedYear,
        ),
      );
    } catch (error, stackTrace) {
      if (!_isLatestDataRequest(requestId) || emit.isDone) {
        return;
      }
      _logger.error(
        'HomeBloc',
        'load failed requestId=$requestId',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          selectionStatus: AsyncStatus.idle,
          completionStatus: AsyncStatus.idle,
          starnyxs: const <StarNyx>[],
          activeStarnyxId: null,
          progressStats: null,
          completedDatesForViewedYear: const <DateTime>[],
        ),
      );
    }
  }

  Future<void> _onActiveStarnyxSelected(
    HomeActiveStarnyxSelected event,
    Emitter<HomeState> emit,
  ) async {
    final today = DateUtils.nowDate(_nowBuilder());
    final requestId = _nextDataRequestId();
    _logger.debug(
      'HomeBloc',
      'select active begin id=${event.id} requestId=$requestId',
    );
    emit(
      state.copyWith(
        selectionStatus: AsyncStatus.inProgress,
        lastSelectionRequestedId: event.id,
      ),
    );

    try {
      await _selectActiveStarNyxUseCase(event.id, now: today);
      final data = await _loadHomeData(
        viewedYear: state.viewedYear,
        today: today,
      );
      if (!_isLatestDataRequest(requestId) || emit.isDone) {
        return;
      }
      _logger.debug('HomeBloc', 'select active success id=${event.id}');
      emit(
        state.copyWith(
          status: HomeStatus.success,
          selectionStatus: AsyncStatus.success,
          starnyxs: data.starnyxs,
          activeStarnyxId: data.activeStarnyx?.id,
          progressStats: data.progressStats,
          completedDatesForViewedYear: data.completedDatesForViewedYear,
          lastSelectionRequestedId: null,
          selectionFeedbackCount: state.selectionFeedbackCount + 1,
        ),
      );
    } catch (error, stackTrace) {
      if (!_isLatestDataRequest(requestId) || emit.isDone) {
        return;
      }
      _logger.error(
        'HomeBloc',
        'select active failed id=${event.id}',
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

  void _onDaySelected(HomeDaySelected event, Emitter<HomeState> emit) {
    final selectedDate = DateUtils.dateOnly(event.date);
    final nextYear = selectedDate.year;
    _logger.debug(
      'HomeBloc',
      'day selected date=$selectedDate previous=${state.selectedDate}',
    );
    if (nextYear != state.viewedYear) {
      add(HomeYearChanged(nextYear));
      emit(state.copyWith(selectedDate: selectedDate, viewedYear: nextYear));
      return;
    }

    emit(state.copyWith(selectedDate: selectedDate, viewedYear: nextYear));
  }

  void _onPreviousDayRequested(
    HomePreviousDayRequested event,
    Emitter<HomeState> emit,
  ) {
    add(HomeDaySelected(state.selectedDate.subtract(const Duration(days: 1))));
  }

  void _onNextDayRequested(
    HomeNextDayRequested event,
    Emitter<HomeState> emit,
  ) {
    add(HomeDaySelected(state.selectedDate.add(const Duration(days: 1))));
  }

  void _onJumpToTodayRequested(
    HomeJumpToTodayRequested event,
    Emitter<HomeState> emit,
  ) {
    add(HomeDaySelected(DateUtils.nowDate(_nowBuilder())));
  }

  Future<void> _onYearChanged(
    HomeYearChanged event,
    Emitter<HomeState> emit,
  ) async {
    final normalizedToday = DateUtils.nowDate(_nowBuilder());
    final requestId = _nextDataRequestId();
    final nextSelectedDate = _sameMonthDayInYear(
      date: state.selectedDate,
      year: event.year,
    );
    _logger.debug(
      'HomeBloc',
      'year changed year=${event.year} requestId=$requestId',
    );
    emit(
      state.copyWith(viewedYear: event.year, selectedDate: nextSelectedDate),
    );

    final activeId = state.activeStarnyxId;
    if (activeId == null) {
      emit(
        state.copyWith(
          completedDatesForViewedYear: const <DateTime>[],
          progressStats: null,
        ),
      );
      return;
    }

    try {
      final stats = await _loadStarNyxProgressStatsUseCase(
        starnyxId: activeId,
        year: event.year,
        today: normalizedToday,
      );
      final completedDates = await _loadStarNyxCompletionDatesForYearUseCase(
        starnyxId: activeId,
        year: event.year,
      );
      if (!_isLatestDataRequest(requestId) || emit.isDone) {
        return;
      }
      emit(
        state.copyWith(
          progressStats: stats,
          completedDatesForViewedYear: completedDates,
        ),
      );
    } catch (error, stackTrace) {
      if (!_isLatestDataRequest(requestId) || emit.isDone) {
        return;
      }
      _logger.error(
        'HomeBloc',
        'year load failed year=${event.year}',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          progressStats: null,
          completedDatesForViewedYear: const <DateTime>[],
        ),
      );
    }
  }

  Future<void> _onCompletionToggled(
    HomeCompletionToggled event,
    Emitter<HomeState> emit,
  ) async {
    final activeId = state.activeStarnyxId;
    if (activeId == null) {
      _logger.debug('HomeBloc', 'completion toggle ignored: no active starnyx');
      return;
    }
    final today = DateUtils.nowDate(_nowBuilder());
    final activeStarnyx = _findActiveStarnyxById(activeId);
    if (_isBlockedCompletionDate(
      selectedDate: state.selectedDate,
      activeStarnyx: activeStarnyx,
      today: today,
    )) {
      _logger.debug(
        'HomeBloc',
        'completion toggle blocked activeId=$activeId date=${state.selectedDate}',
      );
      emit(
        state.copyWith(
          completionStatus: AsyncStatus.failure,
          completionFeedbackCount: state.completionFeedbackCount + 1,
        ),
      );
      return;
    }
    final requestId = _nextDataRequestId();
    _logger.debug(
      'HomeBloc',
      'completion toggle begin activeId=$activeId date=${state.selectedDate} '
          'requestId=$requestId',
    );
    emit(state.copyWith(completionStatus: AsyncStatus.inProgress));

    try {
      await _toggleCompletionUseCase(
        starnyxId: activeId,
        date: state.selectedDate,
        today: today,
      );

      final data = await _loadHomeData(
        viewedYear: state.viewedYear,
        today: today,
      );
      if (!_isLatestDataRequest(requestId) || emit.isDone) {
        return;
      }
      _logger.debug(
        'HomeBloc',
        'completion toggle success activeId=$activeId date=${state.selectedDate}',
      );
      emit(
        state.copyWith(
          completionStatus: AsyncStatus.success,
          completionFeedbackCount: state.completionFeedbackCount + 1,
          progressStats: data.progressStats,
          completedDatesForViewedYear: data.completedDatesForViewedYear,
          starnyxs: data.starnyxs,
          activeStarnyxId: data.activeStarnyx?.id,
        ),
      );
    } catch (error, stackTrace) {
      if (!_isLatestDataRequest(requestId) || emit.isDone) {
        return;
      }
      _logger.error(
        'HomeBloc',
        'completion toggle failed activeId=$activeId date=${state.selectedDate}',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          completionStatus: AsyncStatus.failure,
          completionFeedbackCount: state.completionFeedbackCount + 1,
        ),
      );
    }
  }

  Future<void> _onStarNyxOrderChanged(
    HomeStarNyxOrderChanged event,
    Emitter<HomeState> emit,
  ) async {
    final ordered = _orderStateStarnyxs(event.orderedIds);
    if (ordered.isEmpty) {
      return;
    }

    emit(state.copyWith(starnyxs: ordered));

    final saveOrder = _saveStarNyxOrderUseCase;
    if (saveOrder == null) {
      return;
    }

    final orderedIds = ordered.map((item) => item.id).toList(growable: false);
    try {
      _logger.debug(
        'HomeBloc',
        'starnyx order save begin count=${orderedIds.length}',
      );
      await saveOrder(orderedIds);
      _logger.debug('HomeBloc', 'starnyx order save success');
    } catch (error, stackTrace) {
      _logger.error(
        'HomeBloc',
        'starnyx order save failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<_HomeData> _loadHomeData({
    required int viewedYear,
    required DateTime today,
  }) async {
    final starnyxs = await _loadStarnyxsUseCase();
    final activeStarnyx = await _loadActiveStarNyxUseCase(now: today);

    return _loadHomeDataForActiveStarnyx(
      starnyxs: starnyxs,
      activeStarnyx: activeStarnyx,
      viewedYear: viewedYear,
      today: today,
    );
  }

  Future<_HomeData> _loadHomeDataForActiveStarnyx({
    required List<StarNyx> starnyxs,
    required StarNyx? activeStarnyx,
    required int viewedYear,
    required DateTime today,
  }) async {
    if (activeStarnyx == null) {
      return _HomeData(
        starnyxs: starnyxs,
        activeStarnyx: null,
        completedDatesForViewedYear: const <DateTime>[],
        progressStats: null,
      );
    }

    final progressStats = await _loadStarNyxProgressStatsUseCase(
      starnyxId: activeStarnyx.id,
      year: viewedYear,
      today: today,
    );
    final completedDatesForViewedYear =
        await _loadStarNyxCompletionDatesForYearUseCase(
          starnyxId: activeStarnyx.id,
          year: viewedYear,
        );
    return _HomeData(
      starnyxs: starnyxs,
      activeStarnyx: activeStarnyx,
      completedDatesForViewedYear: completedDatesForViewedYear,
      progressStats: progressStats,
    );
  }

  DateTime _sameMonthDayInYear({required DateTime date, required int year}) {
    final maxDay = DateTime(year, date.month + 1, 0).day;
    final day = date.day <= maxDay ? date.day : maxDay;
    return DateTime(year, date.month, day);
  }

  _HomeLoadContext _resolveLoadContext({
    required HomeEvent event,
    required DateTime today,
  }) {
    if (event is HomeReloadRequested && state.status != HomeStatus.initial) {
      return _HomeLoadContext(
        selectedDate: state.selectedDate,
        viewedYear: state.viewedYear,
      );
    }

    return _HomeLoadContext(selectedDate: today, viewedYear: today.year);
  }

  int _nextDataRequestId() => ++_latestDataRequestId;

  bool _isLatestDataRequest(int requestId) => requestId == _latestDataRequestId;

  StarNyx? _findActiveStarnyxById(String activeId) {
    for (final starnyx in state.starnyxs) {
      if (starnyx.id == activeId) {
        return starnyx;
      }
    }
    return null;
  }

  List<StarNyx> _orderStateStarnyxs(List<String> orderedIds) {
    if (orderedIds.isEmpty || state.starnyxs.isEmpty) {
      return state.starnyxs;
    }

    final byId = <String, StarNyx>{
      for (final starnyx in state.starnyxs) starnyx.id: starnyx,
    };
    final ordered = <StarNyx>[];
    final usedIds = <String>{};
    for (final id in orderedIds) {
      final starnyx = byId[id];
      if (starnyx != null && usedIds.add(id)) {
        ordered.add(starnyx);
      }
    }

    for (final starnyx in state.starnyxs) {
      if (usedIds.add(starnyx.id)) {
        ordered.add(starnyx);
      }
    }

    return <StarNyx>[
      for (var index = 0; index < ordered.length; index += 1)
        ordered[index].copyWith(displayOrder: index),
    ];
  }

  bool _isBlockedCompletionDate({
    required DateTime selectedDate,
    required StarNyx? activeStarnyx,
    required DateTime today,
  }) {
    if (DateUtils.isFutureDate(selectedDate, today: today)) {
      return true;
    }
    if (activeStarnyx == null) {
      return false;
    }
    if (DateUtils.isBeforeStartDate(
      selectedDate,
      startDate: activeStarnyx.startDate,
    )) {
      return true;
    }

    return !DateUtils.isEditableWithinDays(selectedDate, days: 7, today: today);
  }
}

class _HomeData {
  const _HomeData({
    required this.starnyxs,
    required this.activeStarnyx,
    required this.completedDatesForViewedYear,
    required this.progressStats,
  });

  final List<StarNyx> starnyxs;
  final StarNyx? activeStarnyx;
  final List<DateTime> completedDatesForViewedYear;
  final StarNyxProgressStats? progressStats;
}

class _HomeLoadContext {
  const _HomeLoadContext({
    required this.selectedDate,
    required this.viewedYear,
  });

  final DateTime selectedDate;
  final int viewedYear;
}

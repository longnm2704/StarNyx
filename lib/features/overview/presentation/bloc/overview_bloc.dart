import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starnyx/core/constants/enums.dart';
import 'package:starnyx/core/services/app_log_service.dart';
import 'package:starnyx/core/utils/date_utils.dart';
import 'package:starnyx/domain/usecases/load_overview_stats_use_case.dart';

import 'overview_event.dart';
import 'overview_state.dart';

/// Owns the Overview tab's aggregated stats and range selection.
class OverviewBloc extends Bloc<OverviewEvent, OverviewState> {
  OverviewBloc({
    required LoadOverviewStatsUseCase loadOverviewStatsUseCase,
    AppLogService logger = const NoOpAppLogService(),
    DateTime Function()? nowBuilder,
  }) : _loadOverviewStatsUseCase = loadOverviewStatsUseCase,
       _logger = logger,
       _nowBuilder = nowBuilder ?? DateTime.now,
       super(OverviewState(year: (nowBuilder ?? DateTime.now)().year)) {
    on<OverviewLoadRequested>(_onLoadRequested);
    on<OverviewReloadRequested>(_onLoadRequested);
    on<OverviewRangeChanged>(_onRangeChanged);
  }

  final LoadOverviewStatsUseCase _loadOverviewStatsUseCase;
  final AppLogService _logger;
  final DateTime Function() _nowBuilder;
  int _latestRequestId = 0;

  Future<void> _onLoadRequested(
    OverviewEvent event,
    Emitter<OverviewState> emit,
  ) async {
    final today = DateUtils.nowDate(_nowBuilder());
    final year = state.status == OverviewStatus.initial
        ? today.year
        : state.year;
    await _load(year: year, range: state.range, today: today, emit: emit);
  }

  Future<void> _onRangeChanged(
    OverviewRangeChanged event,
    Emitter<OverviewState> emit,
  ) async {
    if (event.range == state.range) {
      return;
    }
    final today = DateUtils.nowDate(_nowBuilder());
    await _load(year: state.year, range: event.range, today: today, emit: emit);
  }

  Future<void> _load({
    required int year,
    required OverviewRange range,
    required DateTime today,
    required Emitter<OverviewState> emit,
  }) async {
    final requestId = ++_latestRequestId;
    _logger.debug(
      'OverviewBloc',
      'load begin year=$year range=$range requestId=$requestId',
    );
    emit(
      state.copyWith(
        status: OverviewStatus.loading,
        year: year,
        range: range,
        stats: null,
      ),
    );

    try {
      final stats = await _loadOverviewStatsUseCase(
        year: year,
        range: range,
        today: today,
      );
      if (requestId != _latestRequestId || emit.isDone) {
        _logger.debug(
          'OverviewBloc',
          'load ignored stale requestId=$requestId',
        );
        return;
      }
      _logger.debug(
        'OverviewBloc',
        'load success year=$year range=$range habits=${stats.habitCount}',
      );
      emit(state.copyWith(status: OverviewStatus.success, stats: stats));
    } catch (error, stackTrace) {
      if (requestId != _latestRequestId || emit.isDone) {
        return;
      }
      _logger.error(
        'OverviewBloc',
        'load failed year=$year range=$range',
        error: error,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(status: OverviewStatus.failure, stats: null));
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/usecases/load_starnyxs_use_case.dart';
import 'package:starnyx/features/home/presentation/bloc/home_event.dart';
import 'package:starnyx/features/home/presentation/bloc/home_state.dart';
import 'package:starnyx/domain/usecases/load_active_starnyx_use_case.dart';
import 'package:starnyx/domain/usecases/select_active_starnyx_use_case.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required LoadStarnyxsUseCase loadStarnyxsUseCase,
    required LoadActiveStarNyxUseCase loadActiveStarNyxUseCase,
    required SelectActiveStarNyxUseCase selectActiveStarNyxUseCase,
    DateTime Function()? nowBuilder,
  }) : _loadStarnyxsUseCase = loadStarnyxsUseCase,
       _loadActiveStarNyxUseCase = loadActiveStarNyxUseCase,
       _selectActiveStarNyxUseCase = selectActiveStarNyxUseCase,
       _nowBuilder = nowBuilder ?? DateTime.now,
       super(const HomeState.initial()) {
    on<HomeLoadRequested>(_onLoadRequested);
    on<HomeReloadRequested>(_onLoadRequested);
    on<HomeActiveStarnyxSelected>(_onActiveStarnyxSelected);
  }

  final LoadStarnyxsUseCase _loadStarnyxsUseCase;
  final LoadActiveStarNyxUseCase _loadActiveStarNyxUseCase;
  final SelectActiveStarNyxUseCase _selectActiveStarNyxUseCase;
  final DateTime Function() _nowBuilder;

  Future<void> _onLoadRequested(
    HomeEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        status: HomeStatus.loading,
        selectionStatus: HomeSelectionStatus.idle,
      ),
    );

    try {
      final data = await _loadHomeData();
      emit(
        state.copyWith(
          status: HomeStatus.success,
          selectionStatus: HomeSelectionStatus.idle,
          starnyxs: data.starnyxs,
          activeStarnyxId: data.activeStarnyx?.id,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          selectionStatus: HomeSelectionStatus.idle,
          starnyxs: const <StarNyx>[],
          activeStarnyxId: null,
        ),
      );
    }
  }

  Future<void> _onActiveStarnyxSelected(
    HomeActiveStarnyxSelected event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(selectionStatus: HomeSelectionStatus.inProgress));

    try {
      await _selectActiveStarNyxUseCase(event.id, now: _nowBuilder());
      final data = await _loadHomeData();
      emit(
        state.copyWith(
          status: HomeStatus.success,
          selectionStatus: HomeSelectionStatus.success,
          starnyxs: data.starnyxs,
          activeStarnyxId: data.activeStarnyx?.id,
          selectionFeedbackCount: state.selectionFeedbackCount + 1,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          selectionStatus: HomeSelectionStatus.failure,
          selectionFeedbackCount: state.selectionFeedbackCount + 1,
        ),
      );
    }
  }

  Future<_HomeData> _loadHomeData() async {
    final starnyxs = await _loadStarnyxsUseCase();
    final activeStarnyx = await _loadActiveStarNyxUseCase(now: _nowBuilder());
    return _HomeData(starnyxs: starnyxs, activeStarnyx: activeStarnyx);
  }
}

class _HomeData {
  const _HomeData({required this.starnyxs, required this.activeStarnyx});

  final List<StarNyx> starnyxs;
  final StarNyx? activeStarnyx;
}

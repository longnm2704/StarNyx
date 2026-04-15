import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:starnyx/domain/usecases/load_starnyxs_use_case.dart';
import 'package:starnyx/features/home/presentation/bloc/home_bloc.dart';
import 'package:starnyx/domain/usecases/toggle_completion_use_case.dart';
import 'package:starnyx/features/home/presentation/bloc/home_event.dart';
import 'package:starnyx/features/home/presentation/bloc/home_state.dart';
import 'package:starnyx/domain/usecases/load_active_starnyx_use_case.dart';
import 'package:starnyx/domain/usecases/select_active_starnyx_use_case.dart';
import 'package:starnyx/features/home/presentation/widgets/home_widgets.dart';
import 'package:starnyx/domain/usecases/load_starnyx_progress_stats_use_case.dart';
import 'package:starnyx/domain/usecases/load_starnyx_completion_dates_for_year_use_case.dart';
import 'package:starnyx/features/starnyx_form/presentation/pages/create_starnyx_bottom_sheet.dart';

// Root screen that shows the first-run welcome state until the real home flow lands.
class HomePage extends StatefulWidget {
  HomePage({
    super.key,
    LoadStarnyxsUseCase? loadStarnyxsUseCase,
    LoadActiveStarNyxUseCase? loadActiveStarNyxUseCase,
    SelectActiveStarNyxUseCase? selectActiveStarNyxUseCase,
    LoadStarNyxProgressStatsUseCase? loadStarNyxProgressStatsUseCase,
    LoadStarNyxCompletionDatesForYearUseCase?
    loadStarNyxCompletionDatesForYearUseCase,
    ToggleCompletionUseCase? toggleCompletionUseCase,
    FutureOr<void> Function()? onCreatePressed,
    FutureOr<void> Function(StarNyx)? onEditPressed,
    ValueChanged<StarNyx>? onSelectPressed,
  }) : _loadStarnyxsUseCase =
           loadStarnyxsUseCase ?? serviceLocator<LoadStarnyxsUseCase>(),
       _loadActiveStarNyxUseCase =
           loadActiveStarNyxUseCase ??
           serviceLocator<LoadActiveStarNyxUseCase>(),
       _selectActiveStarNyxUseCase =
           selectActiveStarNyxUseCase ??
           serviceLocator<SelectActiveStarNyxUseCase>(),
       _loadStarNyxProgressStatsUseCase =
           loadStarNyxProgressStatsUseCase ??
           serviceLocator<LoadStarNyxProgressStatsUseCase>(),
       _loadStarNyxCompletionDatesForYearUseCase =
           loadStarNyxCompletionDatesForYearUseCase ??
           serviceLocator<LoadStarNyxCompletionDatesForYearUseCase>(),
       _toggleCompletionUseCase =
           toggleCompletionUseCase ?? serviceLocator<ToggleCompletionUseCase>(),
       _onCreatePressed = onCreatePressed,
       _onEditPressed = onEditPressed,
       _onSelectPressed = onSelectPressed;

  final LoadStarnyxsUseCase _loadStarnyxsUseCase;
  final LoadActiveStarNyxUseCase _loadActiveStarNyxUseCase;
  final SelectActiveStarNyxUseCase _selectActiveStarNyxUseCase;
  final LoadStarNyxProgressStatsUseCase _loadStarNyxProgressStatsUseCase;
  final LoadStarNyxCompletionDatesForYearUseCase
  _loadStarNyxCompletionDatesForYearUseCase;
  final ToggleCompletionUseCase _toggleCompletionUseCase;
  final FutureOr<void> Function()? _onCreatePressed;
  final FutureOr<void> Function(StarNyx)? _onEditPressed;
  final ValueChanged<StarNyx>? _onSelectPressed;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeBloc _homeBloc;

  @override
  void initState() {
    super.initState();
    _homeBloc = HomeBloc(
      loadStarnyxsUseCase: widget._loadStarnyxsUseCase,
      loadActiveStarNyxUseCase: widget._loadActiveStarNyxUseCase,
      selectActiveStarNyxUseCase: widget._selectActiveStarNyxUseCase,
      loadStarNyxProgressStatsUseCase: widget._loadStarNyxProgressStatsUseCase,
      loadStarNyxCompletionDatesForYearUseCase:
          widget._loadStarNyxCompletionDatesForYearUseCase,
      toggleCompletionUseCase: widget._toggleCompletionUseCase,
    )..add(const HomeLoadRequested());
  }

  @override
  void dispose() {
    _homeBloc.close();
    super.dispose();
  }

  void _retryLoad() {
    _homeBloc.add(const HomeReloadRequested());
  }

  Future<void> _onCreatePressed() async {
    if (widget._onCreatePressed != null) {
      await Future.sync(widget._onCreatePressed!);
      return;
    }

    await _openCreateBottomSheet();
  }

  Future<void> _openCreateBottomSheet() async {
    final result = await showCreateStarnyxBottomSheet(context);
    if (!mounted || result == null || !result.hasChanges) {
      return;
    }

    final saved = result.savedStarnyx;
    if (saved != null) {
      _homeBloc.add(HomeActiveStarnyxSelected(saved.id));
    } else {
      _homeBloc.add(const HomeReloadRequested());
    }
  }

  Future<void> _onEditPressed(StarNyx starnyx) async {
    if (widget._onEditPressed != null) {
      await Future.sync(() => widget._onEditPressed!(starnyx));
      return;
    }

    await _openEditBottomSheet(starnyx);
  }

  Future<void> _openEditBottomSheet(StarNyx starnyx) async {
    final result = await showEditStarnyxBottomSheet(context, starnyx);
    if (!mounted || result == null || !result.hasChanges) {
      return;
    }

    _homeBloc.add(const HomeReloadRequested());
  }

  Future<void> _onSelectPressed(StarNyx starnyx) async {
    if (widget._onSelectPressed != null) {
      widget._onSelectPressed!(starnyx);
      return;
    }
    _homeBloc.add(HomeActiveStarnyxSelected(starnyx.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>.value(
      value: _homeBloc,
      child: BlocListener<HomeBloc, HomeState>(
        listenWhen: (HomeState previous, HomeState current) =>
            previous.selectionFeedbackCount != current.selectionFeedbackCount ||
            previous.completionFeedbackCount != current.completionFeedbackCount,
        listener: (BuildContext context, HomeState state) {
          if (state.selectionStatus == AsyncStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('home.switch_error_message'.tr())),
            );
          }
          if (state.completionStatus == AsyncStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('home.checkin_success_message'.tr())),
            );
          } else if (state.completionStatus == AsyncStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('home.checkin_error_message'.tr())),
            );
          }
        },
        child: Scaffold(
          body: BlocBuilder<HomeBloc, HomeState>(
            builder: (BuildContext context, HomeState state) {
              if (state.status == HomeStatus.initial ||
                  state.status == HomeStatus.loading) {
                return const HomeLoadingView();
              }

              if (state.status == HomeStatus.failure) {
                return HomeErrorView(onRetry: _retryLoad);
              }

              if (state.starnyxs.isEmpty) {
                return FirstRunWelcomeView(onCreatePressed: _onCreatePressed);
              }

              return ActiveStarnyxHomeView(
                starnyxs: state.starnyxs,
                activeStarnyxId: state.activeStarnyxId,
                selectedDate: state.selectedDate,
                todayDate: DateTime.now(),
                viewedYear: state.viewedYear,
                completedDatesForViewedYear: state.completedDatesForViewedYear,
                onCreatePressed: _onCreatePressed,
                onEditPressed: _onEditPressed,
                onDateSelected: (DateTime date) {
                  _homeBloc.add(HomeDaySelected(date));
                },
                onSelectPressed: _onSelectPressed,
                onToggleCompletionPressed: () {
                  _homeBloc.add(const HomeCompletionToggled());
                },
                isCheckingIn: state.completionStatus == AsyncStatus.inProgress,
                progressStats: state.progressStats,
              );
            },
          ),
        ),
      ),
    );
  }
}

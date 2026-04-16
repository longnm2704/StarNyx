import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starnyx/core/utils/date_utils.dart' as core_date_utils;
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/domain/entities/starnyx_progress_stats.dart';
import 'package:starnyx/features/home/presentation/bloc/home_bloc.dart';
import 'package:starnyx/features/home/presentation/bloc/home_state.dart';
import 'package:starnyx/features/journal/presentation/pages/journal_bottom_sheet.dart';

import 'home_shell_view.dart';
import 'home_swipe_up_hint.dart';
import 'constellation_switcher_sheet.dart';

bool canToggleCompletionForSelectedDate({
  required DateTime selectedDate,
  required DateTime todayDate,
  required DateTime startDate,
}) {
  if (core_date_utils.DateUtils.isFutureDate(selectedDate, today: todayDate)) {
    return false;
  }
  if (core_date_utils.DateUtils.isBeforeStartDate(
    selectedDate,
    startDate: startDate,
  )) {
    return false;
  }
  return core_date_utils.DateUtils.isEditableWithinDays(
    selectedDate,
    days: 7,
    today: todayDate,
  );
}

class ActiveStarnyxHomeView extends StatefulWidget {
  const ActiveStarnyxHomeView({
    required this.starnyxs,
    required this.activeStarnyxId,
    required this.selectedDate,
    required this.todayDate,
    required this.viewedYear,
    required this.completedDatesForViewedYear,
    required this.onCreatePressed,
    required this.onEditPressed,
    required this.onDateSelected,
    required this.onSelectPressed,
    required this.onPreviousDayPressed,
    required this.onNextDayPressed,
    required this.onJumpToTodayPressed,
    required this.onPreviousYearPressed,
    required this.onNextYearPressed,
    required this.onToggleCompletionPressed,
    required this.isCheckingIn,
    this.progressStats,
    super.key,
  });

  final List<StarNyx> starnyxs;
  final String? activeStarnyxId;
  final DateTime selectedDate;
  final DateTime todayDate;
  final int viewedYear;
  final List<DateTime> completedDatesForViewedYear;
  final FutureOr<void> Function() onCreatePressed;
  final FutureOr<void> Function(StarNyx) onEditPressed;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<StarNyx> onSelectPressed;
  final VoidCallback onPreviousDayPressed;
  final VoidCallback onNextDayPressed;
  final VoidCallback onJumpToTodayPressed;
  final VoidCallback onPreviousYearPressed;
  final VoidCallback onNextYearPressed;
  final VoidCallback onToggleCompletionPressed;
  final bool isCheckingIn;
  final StarNyxProgressStats? progressStats;

  @override
  State<ActiveStarnyxHomeView> createState() => _ActiveStarnyxHomeViewState();
}

class _ActiveStarnyxHomeViewState extends State<ActiveStarnyxHomeView> {
  bool _isOpeningSheet = false;

  Future<void> _waitForSheetTransition() {
    return Future<void>.delayed(AppDurations.fast);
  }

  Future<ConstellationSwitcherSheetAction?> _showConstellationSheet() {
    HomeBloc? homeBloc;
    try {
      homeBloc = context.read<HomeBloc>();
    } catch (_) {
      homeBloc = null;
    }

    return showModalBottomSheet<ConstellationSwitcherSheetAction>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.black.withValues(alpha: 0.72),
      builder: (_) {
        if (homeBloc == null) {
          return ConstellationSwitcherSheet(
            starnyxs: widget.starnyxs,
            activeStarnyxId: widget.activeStarnyxId,
            onSelectPressed: widget.onSelectPressed,
          );
        }

        return BlocProvider<HomeBloc>.value(
          value: homeBloc,
          child: BlocBuilder<HomeBloc, HomeState>(
            buildWhen: (HomeState previous, HomeState current) =>
                previous.starnyxs != current.starnyxs ||
                previous.activeStarnyxId != current.activeStarnyxId,
            builder: (BuildContext context, HomeState state) {
              return ConstellationSwitcherSheet(
                starnyxs: state.starnyxs.isEmpty
                    ? widget.starnyxs
                    : state.starnyxs,
                activeStarnyxId:
                    state.activeStarnyxId ?? widget.activeStarnyxId,
                onSelectPressed: widget.onSelectPressed,
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _openConstellationSheet() async {
    if (_isOpeningSheet) {
      return;
    }

    setState(() {
      _isOpeningSheet = true;
    });

    while (mounted) {
      final action = await _showConstellationSheet();

      if (!mounted || action == null) {
        break;
      }

      await _waitForSheetTransition();
      if (!mounted) {
        break;
      }

      switch (action.type) {
        case ConstellationSwitcherSheetActionType.createRequested:
          await Future.sync(widget.onCreatePressed);
        case ConstellationSwitcherSheetActionType.editRequested:
          final starnyx = action.starnyx;
          if (starnyx == null) {
            break;
          }
          await Future.sync(() => widget.onEditPressed(starnyx));
        case ConstellationSwitcherSheetActionType.journalRequested:
          if (widget.activeStarnyxId != null) {
            await showJournalBottomSheet(context, widget.activeStarnyxId!);
          }
      }
      if (!mounted) {
        break;
      }

      await _waitForSheetTransition();
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isOpeningSheet = false;
    });
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    if ((details.primaryVelocity ?? 0) < -240) {
      _openConstellationSheet();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeStarnyx = widget.starnyxs.firstWhere(
      (StarNyx item) => item.id == widget.activeStarnyxId,
      orElse: () => widget.starnyxs.first,
    );
    final canToggleCompletion = canToggleCompletionForSelectedDate(
      selectedDate: widget.selectedDate,
      todayDate: widget.todayDate,
      startDate: activeStarnyx.startDate,
    );
    final canMoveToNextYear = widget.viewedYear < widget.todayDate.year;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragEnd: _handleVerticalDragEnd,
      child: HomeShellView(
        activeStarnyx: activeStarnyx,
        selectedDate: widget.selectedDate,
        todayDate: widget.todayDate,
        viewedYear: widget.viewedYear,
        completedDatesForViewedYear: widget.completedDatesForViewedYear,
        progressStats: widget.progressStats,
        onPreviousDayPressed: widget.onPreviousDayPressed,
        onNextDayPressed: widget.onNextDayPressed,
        onJumpToTodayPressed: widget.onJumpToTodayPressed,
        onDateSelected: widget.onDateSelected,
        onPreviousYearPressed: widget.onPreviousYearPressed,
        onNextYearPressed: canMoveToNextYear ? widget.onNextYearPressed : null,
        onQuickActionsPressed: _openConstellationSheet,
        onToggleCompletionPressed: canToggleCompletion
            ? widget.onToggleCompletionPressed
            : null,
        isCheckingIn: widget.isCheckingIn,
        footer: Center(
          child: HomeSwipeUpHint(
            onTap: _openConstellationSheet,
            isBusy: _isOpeningSheet,
          ),
        ),
      ),
    );
  }
}

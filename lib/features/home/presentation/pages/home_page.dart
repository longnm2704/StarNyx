import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:starnyx/core/services/core_services.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/domain/usecases/load_starnyxs_use_case.dart';
import 'package:starnyx/features/home/presentation/bloc/home_bloc.dart';
import 'package:starnyx/domain/usecases/toggle_completion_use_case.dart';
import 'package:starnyx/features/home/presentation/bloc/home_event.dart';
import 'package:starnyx/features/home/presentation/bloc/home_state.dart';
import 'package:starnyx/domain/usecases/load_active_starnyx_use_case.dart';
import 'package:starnyx/domain/usecases/select_active_starnyx_use_case.dart';
import 'package:starnyx/domain/usecases/load_starnyx_progress_stats_use_case.dart';
import 'package:starnyx/features/settings/presentation/pages/settings_bottom_sheet.dart';
import 'package:starnyx/domain/usecases/load_starnyx_completion_dates_for_year_use_case.dart';
import 'package:starnyx/features/starnyx_form/presentation/widgets/starnyx_form_color_utils.dart';
import 'package:starnyx/features/starnyx_form/presentation/pages/create_starnyx_bottom_sheet.dart';

import 'home_body_builder.dart';

// Root screen — owns the HomeBloc lifecycle and top-level navigation callbacks.
// Presentation details (state-to-widget mapping, transition animation) are
// delegated to HomeBodyBuilder and HomeScreenSwitcher respectively.
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
    Color? initialAccentColor,
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
       _onSelectPressed = onSelectPressed,
       _initialAccentColor = initialAccentColor;

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
  final Color? _initialAccentColor;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeBloc _homeBloc;
  Color? _lastActiveAccentColor;
  Color? _lastSavedAccentColor;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _lastActiveAccentColor = widget._initialAccentColor;
    _lastSavedAccentColor = widget._initialAccentColor;
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

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Returns the active [StarNyx] from [state], or `null` when unavailable.
  /// Single source of truth — used by both accent-color resolution and
  /// the create bottom-sheet so the look-up logic is never duplicated.
  StarNyx? _resolveActiveStarnyx(HomeState state) {
    if (state.activeStarnyxId == null || state.starnyxs.isEmpty) return null;
    return state.starnyxs.firstWhere(
      (s) => s.id == state.activeStarnyxId,
      orElse: () => state.starnyxs.first,
    );
  }

  Color? _resolveActiveAccentColor(HomeState state) {
    final starnyx = _resolveActiveStarnyx(state);
    if (starnyx == null) return null;
    return starnyxColorFromHex(starnyx.color);
  }

  void _cacheActiveAccentColor(Color color) {
    if (_lastSavedAccentColor == color) return;
    _lastSavedAccentColor = color;
    if (serviceLocator.isRegistered<ActiveStarnyxColorCache>()) {
      unawaited(serviceLocator<ActiveStarnyxColorCache>().saveColor(color));
    }
  }

  // ── Navigation / callback handlers ────────────────────────────────────────

  Future<void> _onCreatePressed() async {
    if (widget._onCreatePressed != null) {
      await Future.sync(widget._onCreatePressed!);
      return;
    }
    await _openCreateBottomSheet();
  }

  Future<void> _onSettingsPressed() async {
    // _lastActiveAccentColor is always kept up-to-date by the BlocConsumer
    // listener, so no need to re-resolve from the BLoC state here.
    await showSettingsBottomSheet(context, accentColor: _lastActiveAccentColor);
  }

  Future<void> _openCreateBottomSheet() async {
    // Reuse _resolveActiveStarnyx to avoid duplicating the look-up logic.
    final activeColorHex =
        _resolveActiveStarnyx(_homeBloc.state)?.color;

    final result = await showCreateStarnyxBottomSheet(
      context,
      initialColor: activeColorHex,
    );
    if (!mounted || result == null || !result.hasChanges) return;

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
    if (!mounted || result == null || !result.hasChanges) return;
    _homeBloc.add(const HomeReloadRequested());
  }

  // No longer async — neither branch awaits anything.
  void _onSelectPressed(StarNyx starnyx) {
    if (widget._onSelectPressed != null) {
      widget._onSelectPressed!(starnyx);
      return;
    }
    _homeBloc.add(HomeActiveStarnyxSelected(starnyx.id));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>.value(
      value: _homeBloc,
      child: Scaffold(
        body: BlocConsumer<HomeBloc, HomeState>(
          // Fire the listener when:
          //   • feedback counters increment (selection / completion events), or
          //   • the active starnyx identity changes (accent colour may differ).
          listenWhen: (HomeState previous, HomeState current) =>
              previous.selectionFeedbackCount !=
                  current.selectionFeedbackCount ||
              previous.completionFeedbackCount !=
                  current.completionFeedbackCount ||
              previous.activeStarnyxId != current.activeStarnyxId ||
              previous.starnyxs != current.starnyxs,
          listener: _onStateChange,
          builder: (BuildContext context, HomeState state) {
            // Pure build — no side-effects. Accent colour is maintained by the
            // listener above, so _lastActiveAccentColor is always fresh before
            // this builder runs (BlocConsumer fires listener before builder).
            return HomeBodyBuilder(
              state: state,
              accentColor: _lastActiveAccentColor ?? AppColors.background,
              onRetry: () => _homeBloc.add(const HomeReloadRequested()),
              onCreatePressed: _onCreatePressed,
              onSettingsPressed: _onSettingsPressed,
              onEditPressed: _onEditPressed,
              onSelectPressed: _onSelectPressed,
              onDateSelected: (DateTime date) =>
                  _homeBloc.add(HomeDaySelected(date)),
              onPreviousDayPressed: () =>
                  _homeBloc.add(const HomePreviousDayRequested()),
              onNextDayPressed: () =>
                  _homeBloc.add(const HomeNextDayRequested()),
              onJumpToTodayPressed: () =>
                  _homeBloc.add(const HomeJumpToTodayRequested()),
              onPreviousYearPressed: () =>
                  _homeBloc.add(HomeYearChanged(state.viewedYear - 1)),
              onNextYearPressed: () =>
                  _homeBloc.add(HomeYearChanged(state.viewedYear + 1)),
              onToggleCompletionPressed: () =>
                  _homeBloc.add(const HomeCompletionToggled()),
            );
          },
        ),
      ),
    );
  }

  /// Handles side-effects triggered by state changes:
  ///   1. Keeps [_lastActiveAccentColor] in sync (+ persists to disk cache).
  ///   2. Shows error snackbars and triggers haptic feedback.
  void _onStateChange(BuildContext context, HomeState state) {
    // ── Accent colour ──────────────────────────────────────────────────────
    final resolvedColor = _resolveActiveAccentColor(state);
    if (resolvedColor != null) {
      _lastActiveAccentColor = resolvedColor;
      _cacheActiveAccentColor(resolvedColor);
    }

    // ── Selection feedback ─────────────────────────────────────────────────
    if (state.selectionStatus == AsyncStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('home.switch_error_message'.tr()),
          action: state.lastSelectionRequestedId == null
              ? null
              : SnackBarAction(
                  label: 'home.retry'.tr(),
                  onPressed: () => _homeBloc.add(
                    HomeActiveStarnyxSelected(
                      state.lastSelectionRequestedId!,
                    ),
                  ),
                ),
        ),
      );
    }

    // ── Completion feedback ────────────────────────────────────────────────
    if (state.completionStatus == AsyncStatus.success) {
      HapticFeedback.lightImpact();
    } else if (state.completionStatus == AsyncStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('home.checkin_error_message'.tr())),
      );
    }
  }
}

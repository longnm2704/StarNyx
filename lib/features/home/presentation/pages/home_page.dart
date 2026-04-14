import 'dart:async';

import 'package:flutter/material.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:starnyx/domain/usecases/load_starnyxs_use_case.dart';
import 'package:starnyx/domain/usecases/load_active_starnyx_use_case.dart';
import 'package:starnyx/domain/usecases/select_active_starnyx_use_case.dart';
import 'package:starnyx/features/home/presentation/widgets/home_widgets.dart';
import 'package:starnyx/features/starnyx_form/presentation/pages/create_starnyx_bottom_sheet.dart';

// Root screen that shows the first-run welcome state until the real home flow lands.
class HomePage extends StatefulWidget {
  HomePage({
    super.key,
    LoadStarnyxsUseCase? loadStarnyxsUseCase,
    LoadActiveStarNyxUseCase? loadActiveStarNyxUseCase,
    SelectActiveStarNyxUseCase? selectActiveStarNyxUseCase,
    FutureOr<void> Function()? onCreatePressed,
    ValueChanged<StarNyx>? onEditPressed,
    ValueChanged<StarNyx>? onSelectPressed,
  }) : _loadStarnyxsUseCase =
           loadStarnyxsUseCase ?? serviceLocator<LoadStarnyxsUseCase>(),
       _loadActiveStarNyxUseCase =
           loadActiveStarNyxUseCase ??
           serviceLocator<LoadActiveStarNyxUseCase>(),
       _selectActiveStarNyxUseCase =
           selectActiveStarNyxUseCase ??
           serviceLocator<SelectActiveStarNyxUseCase>(),
       _onCreatePressed = onCreatePressed,
       _onEditPressed = onEditPressed,
       _onSelectPressed = onSelectPressed;

  final LoadStarnyxsUseCase _loadStarnyxsUseCase;
  final LoadActiveStarNyxUseCase _loadActiveStarNyxUseCase;
  final SelectActiveStarNyxUseCase _selectActiveStarNyxUseCase;
  final FutureOr<void> Function()? _onCreatePressed;
  final ValueChanged<StarNyx>? _onEditPressed;
  final ValueChanged<StarNyx>? _onSelectPressed;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<_HomePageData> _homeDataFuture;

  @override
  void initState() {
    super.initState();
    _homeDataFuture = _loadHomeData();
  }

  Future<_HomePageData> _loadHomeData() async {
    final starnyxs = await widget._loadStarnyxsUseCase();
    final activeStarnyx = await widget._loadActiveStarNyxUseCase();

    return _HomePageData(starnyxs: starnyxs, activeStarnyx: activeStarnyx);
  }

  void _retryLoad() {
    setState(() {
      _homeDataFuture = _loadHomeData();
    });
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

    _retryLoad();
  }

  void _onEditPressed(StarNyx starnyx) {
    if (widget._onEditPressed != null) {
      widget._onEditPressed!(starnyx);
      return;
    }

    _openEditBottomSheet(starnyx);
  }

  Future<void> _openEditBottomSheet(StarNyx starnyx) async {
    final result = await showEditStarnyxBottomSheet(context, starnyx);
    if (!mounted || result == null || !result.hasChanges) {
      return;
    }

    _retryLoad();
  }

  Future<void> _onSelectPressed(StarNyx starnyx) async {
    if (widget._onSelectPressed != null) {
      widget._onSelectPressed!(starnyx);
      return;
    }

    try {
      await widget._selectActiveStarNyxUseCase(starnyx.id);
      if (!mounted) {
        return;
      }
      _retryLoad();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('home.switch_error_message'.tr())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<_HomePageData>(
        future: _homeDataFuture,
        builder: (BuildContext context, AsyncSnapshot<_HomePageData> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const HomeLoadingView();
          }

          if (snapshot.hasError) {
            return HomeErrorView(onRetry: _retryLoad);
          }

          final homeData = snapshot.data;
          final starnyxs = homeData?.starnyxs ?? const <StarNyx>[];
          if (starnyxs.isEmpty) {
            return FirstRunWelcomeView(onCreatePressed: _onCreatePressed);
          }

          return ReturningPlaceholderView(
            starnyxs: starnyxs,
            activeStarnyxId: homeData?.activeStarnyx?.id,
            onCreatePressed: _onCreatePressed,
            onEditPressed: _onEditPressed,
            onSelectPressed: _onSelectPressed,
          );
        },
      ),
    );
  }
}

class _HomePageData {
  const _HomePageData({required this.starnyxs, required this.activeStarnyx});

  final List<StarNyx> starnyxs;
  final StarNyx? activeStarnyx;
}

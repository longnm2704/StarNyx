import 'package:flutter/material.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/usecases/load_starnyxs_use_case.dart';
import 'package:starnyx/features/home/presentation/widgets/home_widgets.dart';
import 'package:starnyx/features/starnyx_form/presentation/pages/create_starnyx_bottom_sheet.dart';

// Root screen that shows the first-run welcome state until the real home flow lands.
class HomePage extends StatefulWidget {
  HomePage({
    super.key,
    LoadStarnyxsUseCase? loadStarnyxsUseCase,
    VoidCallback? onCreatePressed,
    ValueChanged<StarNyx>? onEditPressed,
  }) : _loadStarnyxsUseCase =
           loadStarnyxsUseCase ?? serviceLocator<LoadStarnyxsUseCase>(),
       _onCreatePressed = onCreatePressed,
       _onEditPressed = onEditPressed;

  final LoadStarnyxsUseCase _loadStarnyxsUseCase;
  final VoidCallback? _onCreatePressed;
  final ValueChanged<StarNyx>? _onEditPressed;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<StarNyx>> _starnyxsFuture;

  @override
  void initState() {
    super.initState();
    _starnyxsFuture = widget._loadStarnyxsUseCase();
  }

  void _retryLoad() {
    setState(() {
      _starnyxsFuture = widget._loadStarnyxsUseCase();
    });
  }

  void _onCreatePressed() {
    if (widget._onCreatePressed != null) {
      widget._onCreatePressed!();
      return;
    }

    _openCreateBottomSheet();
  }

  Future<void> _openCreateBottomSheet() async {
    final created = await showCreateStarnyxBottomSheet(context);
    if (!mounted || created == null) {
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
    final updated = await showEditStarnyxBottomSheet(context, starnyx);
    if (!mounted || updated == null) {
      return;
    }

    _retryLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<StarNyx>>(
        future: _starnyxsFuture,
        builder: (BuildContext context, AsyncSnapshot<List<StarNyx>> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const HomeLoadingView();
          }

          if (snapshot.hasError) {
            return HomeErrorView(onRetry: _retryLoad);
          }

          final starnyxs = snapshot.data ?? const <StarNyx>[];
          if (starnyxs.isEmpty) {
            return FirstRunWelcomeView(onCreatePressed: _onCreatePressed);
          }

          return ReturningPlaceholderView(
            starnyxs: starnyxs,
            onCreatePressed: _onCreatePressed,
            onEditPressed: _onEditPressed,
          );
        },
      ),
    );
  }
}

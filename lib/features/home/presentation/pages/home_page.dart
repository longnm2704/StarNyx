import 'package:flutter/material.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/usecases/load_starnyxs_use_case.dart';
import 'package:starnyx/features/home/presentation/widgets/home_widgets.dart';

// Root screen that shows the first-run welcome state until the real home flow lands.
class HomePage extends StatefulWidget {
  HomePage({
    super.key,
    LoadStarnyxsUseCase? loadStarnyxsUseCase,
    VoidCallback? onCreatePressed,
  }) : _loadStarnyxsUseCase =
           loadStarnyxsUseCase ?? serviceLocator<LoadStarnyxsUseCase>(),
       _onCreatePressed = onCreatePressed;

  final LoadStarnyxsUseCase _loadStarnyxsUseCase;
  final VoidCallback? _onCreatePressed;

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
            return FirstRunWelcomeView(
              onCreatePressed: widget._onCreatePressed,
            );
          }

          return ReturningPlaceholderView(starnyxCount: starnyxs.length);
        },
      ),
    );
  }
}

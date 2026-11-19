import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starnyx/core/constants/enums.dart';
import 'package:starnyx/domain/entities/domain_entities.dart';
import 'package:starnyx/domain/repositories/domain_repositories.dart';
import 'package:starnyx/domain/usecases/load_overview_stats_use_case.dart';
import 'package:starnyx/domain/usecases/load_starnyxs_use_case.dart';
import 'package:starnyx/domain/usecases/load_starnyx_progress_stats_use_case.dart';
import 'package:starnyx/features/overview/presentation/bloc/overview_bloc.dart';
import 'package:starnyx/features/overview/presentation/pages/overview_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    rootBundle.clear();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('renders hero card, stat tiles, heatmap and habit list', (
    tester,
  ) async {
    final starnyxRepository = _InMemoryStarNyxRepository();
    final completionRepository = _InMemoryCompletionRepository();
    await starnyxRepository.saveStarnyx(
      StarNyx(
        id: 'habit-1',
        title: 'Uống nước',
        description: null,
        color: '#10B981',
        startDate: DateTime(2026, 6, 1),
        reminderEnabled: false,
        reminderTime: null,
        createdAt: DateTime(2026, 6, 1, 8),
        updatedAt: DateTime(2026, 6, 1, 8),
      ),
    );
    await completionRepository.saveCompletion(
      Completion(
        starnyxId: 'habit-1',
        date: DateTime(2026, 6, 10),
        completed: true,
      ),
    );

    final bloc = OverviewBloc(
      loadOverviewStatsUseCase: LoadOverviewStatsUseCase(
        LoadStarnyxsUseCase(starnyxRepository),
        completionRepository,
        LoadStarNyxProgressStatsUseCase(
          starnyxRepository,
          completionRepository,
        ),
      ),
      nowBuilder: () => DateTime(2026, 6, 15, 10),
    );

    await _renderOverview(tester, bloc);

    expect(find.text('Tổng quan'), findsWidgets);
    expect(find.text('Đã thắp sáng'), findsOneWidget);
    expect(find.text('Chuỗi dài nhất'), findsOneWidget);
    expect(find.text('Ma Trận Kỷ Luật'), findsOneWidget);
    expect(find.text('Theo Từng Thói Quen'), findsOneWidget);
    expect(find.text('Uống nước'), findsOneWidget);
    // Placeholders are filled, not rendered literally.
    expect(find.text('Năm 2026'), findsOneWidget);
    expect(find.bySemanticsLabel('Ngày 10/6: 1/1 đã thắp'), findsOneWidget);
    expect(find.textContaining(RegExp(r'\{\w*\}')), findsNothing);
  });

  testWidgets('renders multiple habits in the per-habit list', (tester) async {
    final starnyxRepository = _InMemoryStarNyxRepository();
    final completionRepository = _InMemoryCompletionRepository();
    await starnyxRepository.saveStarnyx(
      StarNyx(
        id: 'habit-1',
        title: 'Uống nước',
        description: null,
        color: '#10B981',
        startDate: DateTime(2026, 6, 1),
        reminderEnabled: false,
        reminderTime: null,
        createdAt: DateTime(2026, 6, 1, 8),
        updatedAt: DateTime(2026, 6, 1, 8),
      ),
    );
    await starnyxRepository.saveStarnyx(
      StarNyx(
        id: 'habit-2',
        title: 'Ngủ sớm',
        description: null,
        color: '#DE7B30',
        startDate: DateTime(2026, 6, 1),
        reminderEnabled: false,
        reminderTime: null,
        createdAt: DateTime(2026, 6, 1, 9),
        updatedAt: DateTime(2026, 6, 1, 9),
      ),
    );

    final bloc = OverviewBloc(
      loadOverviewStatsUseCase: LoadOverviewStatsUseCase(
        LoadStarnyxsUseCase(starnyxRepository),
        completionRepository,
        LoadStarNyxProgressStatsUseCase(
          starnyxRepository,
          completionRepository,
        ),
      ),
      nowBuilder: () => DateTime(2026, 6, 15, 10),
    );

    await _renderOverview(tester, bloc);

    expect(find.text('Uống nước'), findsOneWidget);
    expect(find.text('Ngủ sớm'), findsOneWidget);
  });

  testWidgets('range switching dispatches the right event', (tester) async {
    final starnyxRepository = _InMemoryStarNyxRepository();
    final completionRepository = _InMemoryCompletionRepository();
    await starnyxRepository.saveStarnyx(
      StarNyx(
        id: 'habit-1',
        title: 'Uống nước',
        description: null,
        color: '#10B981',
        startDate: DateTime(2026, 6, 1),
        reminderEnabled: false,
        reminderTime: null,
        createdAt: DateTime(2026, 6, 1, 8),
        updatedAt: DateTime(2026, 6, 1, 8),
      ),
    );

    final bloc = OverviewBloc(
      loadOverviewStatsUseCase: LoadOverviewStatsUseCase(
        LoadStarnyxsUseCase(starnyxRepository),
        completionRepository,
        LoadStarNyxProgressStatsUseCase(
          starnyxRepository,
          completionRepository,
        ),
      ),
      nowBuilder: () => DateTime(2026, 6, 15, 10),
    );

    await _renderOverview(tester, bloc);

    expect(bloc.state.range, OverviewRange.week);

    await tester.tap(find.text('Tháng này').first);
    var attempts = 0;
    while (bloc.state.range != OverviewRange.month && attempts++ < 100) {
      await tester.pumpAndSettle();
    }

    expect(bloc.state.range, OverviewRange.month);
  });

  testWidgets('renders empty state when there are no habits', (tester) async {
    final bloc = OverviewBloc(
      loadOverviewStatsUseCase: LoadOverviewStatsUseCase(
        LoadStarnyxsUseCase(_InMemoryStarNyxRepository()),
        _InMemoryCompletionRepository(),
        LoadStarNyxProgressStatsUseCase(
          _InMemoryStarNyxRepository(),
          _InMemoryCompletionRepository(),
        ),
      ),
      nowBuilder: () => DateTime(2026, 6, 15, 10),
    );

    await _renderOverview(tester, bloc);

    expect(find.text('Chưa có thói quen'), findsOneWidget);
    expect(find.text('Tạo thói quen'), findsOneWidget);
  });

  testWidgets('renders error state when stats fail to load', (tester) async {
    final starnyxRepository = _ThrowingStarNyxRepository();
    final completionRepository = _InMemoryCompletionRepository();
    final bloc = OverviewBloc(
      loadOverviewStatsUseCase: LoadOverviewStatsUseCase(
        LoadStarnyxsUseCase(starnyxRepository),
        completionRepository,
        LoadStarNyxProgressStatsUseCase(
          starnyxRepository,
          completionRepository,
        ),
      ),
      nowBuilder: () => DateTime(2026, 6, 15, 10),
    );

    await _renderOverview(tester, bloc);

    expect(find.text('Không thể tải tổng quan'), findsOneWidget);
    expect(find.text('Thử lại'), findsOneWidget);
  });
}

class _ThrowingStarNyxRepository extends _InMemoryStarNyxRepository {
  @override
  Future<List<StarNyx>> getAllStarnyxs() => Future.error(StateError('db'));
}

Future<void> _renderOverview(WidgetTester tester, OverviewBloc bloc) async {
  // Reset the shared test binding's render state left over from the previous
  // test with a directionality-free box before mounting the real page.
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();

  await tester.pumpWidget(_buildViApp(OverviewPage(bloc: bloc)));
  var attempts = 0;
  while ((bloc.state.status != OverviewStatus.success ||
          bloc.state.stats == null) &&
      attempts++ < 100) {
    await tester.pumpAndSettle();
  }
}

Widget _buildViApp(Widget child) {
  return EasyLocalization(
    supportedLocales: const <Locale>[Locale('vi')],
    fallbackLocale: const Locale('vi'),
    path: 'assets/translations',
    useOnlyLangCode: true,
    child: Builder(
      builder: (context) => MaterialApp(
        locale: const Locale('vi'),
        supportedLocales: const <Locale>[Locale('vi')],
        localizationsDelegates: context.localizationDelegates,
        home: Scaffold(body: child),
      ),
    ),
  );
}

class _InMemoryStarNyxRepository implements StarNyxRepository {
  final Map<String, StarNyx> _items = <String, StarNyx>{};

  @override
  Future<void> deleteStarnyxById(String id) async {
    _items.remove(id);
  }

  @override
  Future<List<StarNyx>> getAllStarnyxs() async {
    return _items.values.toList(growable: false);
  }

  @override
  Future<StarNyx?> getStarnyxById(String id) async => _items[id];

  @override
  Future<void> reorderStarnyxs(List<String> orderedIds) async {}

  @override
  Future<void> saveStarnyx(StarNyx starnyx) async {
    _items[starnyx.id] = starnyx;
  }

  @override
  Stream<List<StarNyx>> watchAllStarnyxs() {
    throw UnimplementedError();
  }
}

class _InMemoryCompletionRepository implements CompletionRepository {
  final Map<String, Completion> _items = <String, Completion>{};

  @override
  Future<void> deleteCompletionByDate({
    required String starnyxId,
    required DateTime date,
  }) async {
    _items.remove(_key(starnyxId, date));
  }

  @override
  Future<void> deleteCompletionsForStarnyx(String starnyxId) async {
    _items.removeWhere((_, value) => value.starnyxId == starnyxId);
  }

  @override
  Future<Completion?> getCompletionByDate({
    required String starnyxId,
    required DateTime date,
  }) async {
    return _items[_key(starnyxId, date)];
  }

  @override
  Future<List<Completion>> getCompletionsForStarnyx(String starnyxId) async {
    return _items.values
        .where((item) => item.starnyxId == starnyxId)
        .toList(growable: false);
  }

  @override
  Future<void> saveCompletion(Completion completion) async {
    _items[_key(completion.starnyxId, completion.date)] = completion;
  }

  @override
  Stream<List<Completion>> watchCompletionsForStarnyx(String starnyxId) {
    throw UnimplementedError();
  }
}

String _key(String starnyxId, DateTime date) {
  return '$starnyxId:${date.toIso8601String()}';
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starnyx/domain/entities/domain_entities.dart';
import 'package:starnyx/domain/repositories/domain_repositories.dart';
import 'package:starnyx/domain/usecases/domain_usecases.dart';
import 'package:starnyx/features/home/presentation/pages/home_page.dart';
import 'package:starnyx/features/home/presentation/widgets/first_run_welcome_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('home page shows welcome state when there is no StarNyx', (
    tester,
  ) async {
    final starnyxRepository = _InMemoryStarNyxRepository();
    final completionRepository = _InMemoryCompletionRepository();
    final appSettingsRepository = _InMemoryAppSettingsRepository();

    await tester.pumpWidget(
      _buildLocalizedApp(
        HomePage(
          loadStarnyxsUseCase: LoadStarnyxsUseCase(starnyxRepository),
          loadActiveStarNyxUseCase: LoadActiveStarNyxUseCase(
            starnyxRepository,
            appSettingsRepository,
          ),
          selectActiveStarNyxUseCase: SelectActiveStarNyxUseCase(
            starnyxRepository,
            appSettingsRepository,
          ),
          loadStarNyxProgressStatsUseCase: LoadStarNyxProgressStatsUseCase(
            starnyxRepository,
            completionRepository,
          ),
          loadStarNyxCompletionDatesForYearUseCase:
              LoadStarNyxCompletionDatesForYearUseCase(completionRepository),
          toggleCompletionUseCase: ToggleCompletionUseCase(
            starnyxRepository,
            completionRepository,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(FirstRunWelcomeView), findsOneWidget);
    expect(find.text('New Constellation'), findsOneWidget);
  });

  testWidgets('welcome state stays usable on small screens', (tester) async {
    await tester.pumpWidget(
      _buildLocalizedApp(
        const MediaQuery(
          data: MediaQueryData(size: Size(320, 568)),
          child: SizedBox(
            width: 320,
            height: 568,
            child: FirstRunWelcomeView(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}

Widget _buildLocalizedApp(Widget child) {
  return EasyLocalization(
    supportedLocales: const <Locale>[Locale('en')],
    fallbackLocale: const Locale('en'),
    path: 'assets/translations',
    useOnlyLangCode: true,
    child: Builder(
      builder: (context) {
        return MaterialApp(
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          home: Scaffold(body: child),
        );
      },
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
    final items = _items.values.toList(growable: false);
    items.sort((left, right) => left.createdAt.compareTo(right.createdAt));
    return items;
  }

  @override
  Future<StarNyx?> getStarnyxById(String id) async => _items[id];

  @override
  Future<void> saveStarnyx(StarNyx starnyx) async {
    _items[starnyx.id] = starnyx;
  }

  @override
  Stream<List<StarNyx>> watchAllStarnyxs() async* {
    yield await getAllStarnyxs();
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
    final items = _items.values
        .where((item) => item.starnyxId == starnyxId)
        .toList(growable: false);
    items.sort((left, right) => left.date.compareTo(right.date));
    return items;
  }

  @override
  Future<void> saveCompletion(Completion completion) async {
    _items[_key(completion.starnyxId, completion.date)] = completion;
  }

  @override
  Stream<List<Completion>> watchCompletionsForStarnyx(String starnyxId) async* {
    yield await getCompletionsForStarnyx(starnyxId);
  }
}

class _InMemoryAppSettingsRepository implements AppSettingsRepository {
  AppSettings? _settings;

  @override
  Future<AppSettings?> getAppSettings() async => _settings;

  @override
  Future<void> saveAppSettings(AppSettings settings) async {
    _settings = settings;
  }

  @override
  Stream<AppSettings?> watchAppSettings() async* {
    yield _settings;
  }
}

String _key(String starnyxId, DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  return '$starnyxId:${normalized.toIso8601String()}';
}

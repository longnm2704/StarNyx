import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:starnyx/core/services/core_services.dart';
import 'package:starnyx/domain/entities/domain_entities.dart';
import 'package:starnyx/domain/repositories/domain_repositories.dart';
import 'package:starnyx/domain/usecases/domain_usecases.dart';
import 'package:starnyx/features/habits/presentation/bloc/habit_list_bloc.dart';
import 'package:starnyx/features/habits/presentation/pages/habit_list_page.dart';
import 'package:starnyx/features/starnyx_form/presentation/bloc/starnyx_form_bloc.dart';
import 'package:uuid/uuid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  tearDown(() async {
    await resetDependencies();
  });

  testWidgets(
    'habit list supports render, reorder, edit, empty, and select flows',
    (WidgetTester tester) async {
      final deps = _TestDeps(
        habits: <StarNyx>[_hydrate(), _read()],
        activeId: '2',
        completedTodayHabitIds: <String>['1'],
      );
      final emptyDeps = _TestDeps();
      addTearDown(deps.bloc.close);
      addTearDown(emptyDeps.bloc.close);
      _registerFormDependencies(deps);

      await _pumpLocalized(
        tester,
        _HabitListHost(populated: deps.bloc, empty: emptyDeps.bloc),
      );

      // ── Populated list ──────────────────────────────────────────────────
      await tester.tap(find.byKey(const Key('open-populated')));
      await tester.pumpAndSettle();

      expect(find.text('Habit deck'), findsOneWidget);
      expect(find.text('Current focus'), findsOneWidget);
      expect(find.text('Hydrate'), findsOneWidget);
      expect(find.text('Read'), findsWidgets);
      expect(find.text('09:00 · Drink water'), findsOneWidget);
      expect(find.text('STREAK 1/2 COMPLETE'), findsOneWidget);
      expect(find.byKey(const Key('habit-list-settings')), findsOneWidget);
      expect(find.byKey(const Key('habit-list-journal')), findsOneWidget);
      expect(find.byKey(const Key('habit-list-add')), findsOneWidget);
      expect(find.byKey(const Key('habit-list-edit-1')), findsOneWidget);
      expect(find.byKey(const Key('habit-list-edit-2')), findsOneWidget);

      // ── Reorder mode persists the new order ─────────────────────────────
      await tester.tap(find.byKey(const Key('habit-list-edit-toggle')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('habit-list-drag-1')), findsOneWidget);
      expect(find.byKey(const Key('habit-list-edit-1')), findsNothing);

      final drag = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('habit-list-drag-1'))),
      );
      await tester.pump();
      await drag.moveBy(const Offset(0, 100));
      await tester.pump(const Duration(milliseconds: 120));
      await drag.moveBy(const Offset(0, 60));
      await tester.pump(const Duration(milliseconds: 120));
      await drag.up();
      await tester.pumpAndSettle();

      expect(
        tester
            .getTopLeft(find.byKey(const ValueKey<String>('habit-list-row-2')))
            .dy,
        lessThan(
          tester
              .getTopLeft(
                find.byKey(const ValueKey<String>('habit-list-row-1')),
              )
              .dy,
        ),
      );

      await tester.tap(find.byKey(const Key('habit-list-edit-toggle')));
      await tester.pumpAndSettle();
      expect(deps.starnyxRepository.lastReorderedIds, <String>['2', '1']);

      // ── Edit pencil opens the edit form ─────────────────────────────────
      await tester.tap(find.byKey(const Key('habit-list-edit-1')));
      await tester.pumpAndSettle();
      expect(find.text('Edit habit'), findsOneWidget);

      await tester.tap(find.byType(IconButton).first);
      await tester.pumpAndSettle();
      expect(find.text('Habit deck'), findsOneWidget);

      // ── Empty state ─────────────────────────────────────────────────────
      await tester.tap(find.byKey(const Key('habit-list-back')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('open-empty')));
      await tester.pumpAndSettle();

      expect(find.text('No habits yet'), findsOneWidget);
      expect(find.text('Create habit'), findsOneWidget);
      expect(find.text('STREAK 0/0 COMPLETE'), findsNothing);

      // ── Selecting a row stores the active habit and pops ────────────────
      await tester.tap(find.byKey(const Key('habit-list-back')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('open-populated')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hydrate'));
      await tester.pumpAndSettle();

      expect(deps.settingsRepository.value?.lastSelectedStarnyxId, '1');
      expect(find.byKey(const Key('open-habit-list')), findsOneWidget);
    },
  );
}

class _HabitListHost extends StatelessWidget {
  const _HabitListHost({required this.populated, required this.empty});

  final HabitListBloc populated;
  final HabitListBloc empty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextButton(
              key: const Key('open-habit-list'),
              onPressed: () => _open(context, populated),
              child: const Text('open'),
            ),
            TextButton(
              key: const Key('open-populated'),
              onPressed: () => _open(context, populated),
              child: const Text('open populated'),
            ),
            TextButton(
              key: const Key('open-empty'),
              onPressed: () => _open(context, empty),
              child: const Text('open empty'),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, HabitListBloc bloc) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => HabitListPage(bloc: bloc)));
  }
}

class _TestDeps {
  _TestDeps({
    List<StarNyx> habits = const <StarNyx>[],
    String? activeId,
    List<String> completedTodayHabitIds = const <String>[],
  }) : starnyxRepository = _InMemoryStarNyxRepository(habits),
       settingsRepository = _InMemoryAppSettingsRepository(
         activeId == null
             ? null
             : AppSettings(
                 lastSelectedStarnyxId: activeId,
                 updatedAt: DateTime(2026, 4, 1),
               ),
       ) {
    completionRepository = _InMemoryCompletionRepository(
      completedHabitIds: completedTodayHabitIds,
      completedDate: DateTime(2026, 4, 19),
    );
    bloc = HabitListBloc(
      loadStarnyxsUseCase: LoadStarnyxsUseCase(starnyxRepository),
      loadActiveStarNyxUseCase: LoadActiveStarNyxUseCase(
        starnyxRepository,
        settingsRepository,
      ),
      selectActiveStarNyxUseCase: SelectActiveStarNyxUseCase(
        starnyxRepository,
        settingsRepository,
      ),
      saveStarNyxOrderUseCase: SaveStarNyxOrderUseCase(starnyxRepository),
      countHabitsCompletedOnDateUseCase: CountHabitsCompletedOnDateUseCase(
        completionRepository,
      ),
      nowBuilder: () => DateTime(2026, 4, 19, 10, 30),
    );
  }

  final _InMemoryStarNyxRepository starnyxRepository;
  final _InMemoryAppSettingsRepository settingsRepository;
  late final _InMemoryCompletionRepository completionRepository;
  late final HabitListBloc bloc;
}

void _registerFormDependencies(_TestDeps deps) {
  serviceLocator.registerFactoryParam<StarnyxFormBloc, StarNyx?, void>((
    StarNyx? initialStarnyx,
    void _,
  ) {
    return StarnyxFormBloc(
      createStarNyxUseCase: CreateStarNyxUseCase(
        deps.starnyxRepository,
        const Uuid(),
      ),
      updateStarNyxUseCase: UpdateStarNyxUseCase(deps.starnyxRepository),
      deleteStarNyxUseCase: DeleteStarNyxUseCase(
        deps.starnyxRepository,
        deps.settingsRepository,
      ),
      syncNotificationsUseCase: SyncNotificationsUseCase(
        _FakeNotificationService(),
        deps.starnyxRepository,
      ),
      initialStarnyx: initialStarnyx,
      nowBuilder: () => DateTime(2026, 4, 19, 11),
    );
  });
}

StarNyx _hydrate() {
  return StarNyx(
    id: '1',
    title: 'Hydrate',
    description: 'Drink water',
    color: '#DE7B30',
    startDate: DateTime(2026, 4, 1),
    reminderEnabled: true,
    reminderTime: '09:00',
    createdAt: DateTime(2026, 4, 1, 8),
    updatedAt: DateTime(2026, 4, 1, 8),
  );
}

StarNyx _read() {
  return StarNyx(
    id: '2',
    title: 'Read',
    description: 'Ten quiet pages',
    color: '#2360E9',
    startDate: DateTime(2026, 4, 2),
    reminderEnabled: false,
    reminderTime: null,
    createdAt: DateTime(2026, 4, 2, 8),
    updatedAt: DateTime(2026, 4, 2, 8),
    icon: 'book',
  );
}

Future<void> _pumpLocalized(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(_buildLocalizedApp(child));
  await tester.runAsync(() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  });
  await tester.pumpAndSettle();
}

Widget _buildLocalizedApp(Widget child) {
  return EasyLocalization(
    supportedLocales: const <Locale>[Locale('en')],
    fallbackLocale: const Locale('en'),
    path: 'assets/translations',
    useOnlyLangCode: true,
    child: Builder(
      builder: (BuildContext context) {
        return MaterialApp(
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          home: child,
        );
      },
    ),
  );
}

class _InMemoryStarNyxRepository implements StarNyxRepository {
  _InMemoryStarNyxRepository(List<StarNyx> habits)
    : _items = <String, StarNyx>{for (final habit in habits) habit.id: habit},
      _order = habits.map((habit) => habit.id).toList();

  final Map<String, StarNyx> _items;
  final List<String> _order;
  List<String>? lastReorderedIds;

  @override
  Future<void> deleteStarnyxById(String id) async {
    _items.remove(id);
    _order.remove(id);
  }

  @override
  Future<List<StarNyx>> getAllStarnyxs() async {
    return <StarNyx>[
      for (final id in _order)
        if (_items[id] != null) _items[id]!,
    ];
  }

  @override
  Future<StarNyx?> getStarnyxById(String id) async => _items[id];

  @override
  Future<void> reorderStarnyxs(List<String> orderedIds) async {
    lastReorderedIds = List<String>.of(orderedIds);
    _order
      ..clear()
      ..addAll(orderedIds);
  }

  @override
  Future<void> saveStarnyx(StarNyx starnyx) async {
    if (!_items.containsKey(starnyx.id)) {
      _order.add(starnyx.id);
    }
    _items[starnyx.id] = starnyx;
  }

  @override
  Stream<List<StarNyx>> watchAllStarnyxs() async* {
    yield await getAllStarnyxs();
  }
}

class _InMemoryAppSettingsRepository implements AppSettingsRepository {
  _InMemoryAppSettingsRepository(this.value);

  AppSettings? value;

  @override
  Future<AppSettings?> getAppSettings() async => value;

  @override
  Future<void> saveAppSettings(AppSettings settings) async {
    value = settings;
  }

  @override
  Stream<AppSettings?> watchAppSettings() async* {
    yield value;
  }
}

class _InMemoryCompletionRepository implements CompletionRepository {
  _InMemoryCompletionRepository({
    required List<String> completedHabitIds,
    required DateTime completedDate,
  }) {
    for (final id in completedHabitIds) {
      _completions[_key(id, completedDate)] = Completion(
        starnyxId: id,
        date: DateTime(
          completedDate.year,
          completedDate.month,
          completedDate.day,
        ),
        completed: true,
      );
    }
  }

  final Map<String, Completion> _completions = <String, Completion>{};

  String _key(String starnyxId, DateTime date) {
    return '$starnyxId-${date.year}-${date.month}-${date.day}';
  }

  @override
  Future<void> deleteCompletionByDate({
    required String starnyxId,
    required DateTime date,
  }) async {
    _completions.remove(_key(starnyxId, date));
  }

  @override
  Future<void> deleteCompletionsForStarnyx(String starnyxId) async {
    _completions.removeWhere((key, _) => key.startsWith('$starnyxId-'));
  }

  @override
  Future<Completion?> getCompletionByDate({
    required String starnyxId,
    required DateTime date,
  }) async {
    return _completions[_key(starnyxId, date)];
  }

  @override
  Future<List<Completion>> getCompletionsForStarnyx(String starnyxId) async {
    return _completions.values
        .where((completion) => completion.starnyxId == starnyxId)
        .toList(growable: false);
  }

  @override
  Future<void> saveCompletion(Completion completion) async {
    _completions[_key(completion.starnyxId, completion.date)] = completion;
  }

  @override
  Stream<List<Completion>> watchCompletionsForStarnyx(String starnyxId) {
    return Stream<List<Completion>>.fromIterable(<List<Completion>>[
      _completions.values
          .where((completion) => completion.starnyxId == starnyxId)
          .toList(growable: false),
    ]);
  }
}

class _FakeNotificationService implements NotificationService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> createReminder(StarNyx starnyx) async {}

  @override
  Future<void> updateReminder(StarNyx starnyx) async {}

  @override
  Future<void> cancelReminder(String starnyxId) async {}

  @override
  Future<void> cancelAllReminders() async {}

  @override
  void setTranslator(
    String Function(String key, {Map<String, dynamic>? namedArgs}) tr,
  ) {}
}

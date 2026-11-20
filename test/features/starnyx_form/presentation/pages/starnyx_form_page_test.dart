import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:starnyx/core/services/core_services.dart';
import 'package:starnyx/domain/entities/domain_entities.dart';
import 'package:starnyx/domain/repositories/domain_repositories.dart';
import 'package:starnyx/domain/usecases/domain_usecases.dart';
import 'package:starnyx/features/starnyx_form/presentation/bloc/starnyx_form_bloc.dart';
import 'package:starnyx/features/starnyx_form/presentation/pages/starnyx_form_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _InMemoryStarNyxRepository repository;

  setUp(() async {
    rootBundle.clear();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
    repository = _InMemoryStarNyxRepository();
    _registerFormTestDependencies(repository);
  });

  tearDown(() async {
    await resetDependencies();
  });

  final submit = find.byKey(const Key('starnyx-form-submit'));

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  // A tall view keeps the whole lazy ListView built.
  Future<void> openForm(
    WidgetTester tester,
    Widget host, {
    bool tall = true,
  }) async {
    if (tall) {
      tester.view.physicalSize = const Size(800, 3200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }
    await tester.pumpWidget(_buildLocalizedApp(host));
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  bool submitEnabled(WidgetTester tester) =>
      tester.widget<InkWell>(submit).onTap != null;

  testWidgets('create flow saves the habit and pops a result', (tester) async {
    final host = _FormHost();
    await openForm(tester, host);

    expect(find.text('New habit'), findsOneWidget);
    expect(find.text('Save habit'), findsOneWidget);
    expect(find.text('Delete habit'), findsNothing);

    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('starnyx-form-title')),
        matching: find.byType(EditableText),
      ),
      'Read',
    );
    await tester.pump();
    expect(find.text('4/60'), findsOneWidget);

    await tapVisible(tester, submit);

    expect(find.text('New habit'), findsNothing);
    expect(host.result?.hasChanges, isTrue);
    expect(host.result?.savedStarnyx?.title, 'Read');
    expect((await repository.getAllStarnyxs()).single.title, 'Read');
  });

  testWidgets('edit flow prefills and updates the habit', (tester) async {
    final habit = _habit();
    await repository.saveStarnyx(habit);
    final host = _FormHost(starnyx: habit);
    await openForm(tester, host);

    expect(find.text('Edit habit'), findsOneWidget);
    expect(find.text('Gym'), findsOneWidget);
    expect(find.text('Delete habit'), findsOneWidget);

    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('starnyx-form-title')),
        matching: find.byType(EditableText),
      ),
      'Gym daily',
    );
    await tester.pump();
    await tapVisible(tester, submit);

    expect(host.result?.savedStarnyx?.id, habit.id);
    expect((await repository.getStarnyxById(habit.id))?.title, 'Gym daily');
  });

  testWidgets('selecting a symbol and filtering by category', (tester) async {
    final habit = _habit();
    await repository.saveStarnyx(habit);
    final host = _FormHost(starnyx: habit);
    await openForm(tester, host);

    // Category chip narrows the grid to that group.
    await tapVisible(tester, find.text('ENERGY'));
    expect(find.byKey(const Key('starnyx-form-symbol-flame')), findsOneWidget);
    expect(find.byKey(const Key('starnyx-form-symbol-clover')), findsNothing);

    await tapVisible(
      tester,
      find.byKey(const Key('starnyx-form-symbol-flame')),
    );
    await tapVisible(tester, submit);

    expect(host.result?.savedStarnyx?.icon, 'flame');
  });

  testWidgets('selecting a color updates the name chip', (tester) async {
    final habit = _habit();
    await repository.saveStarnyx(habit);
    final host = _FormHost(starnyx: habit);
    await openForm(tester, host);

    expect(find.text('EMERALD'), findsOneWidget);
    await tapVisible(
      tester,
      find.byKey(const Key('starnyx-form-color-#FFB95F')),
    );
    expect(find.text('AMBER'), findsOneWidget);

    await tapVisible(tester, submit);
    expect(host.result?.savedStarnyx?.color, '#FFB95F');
  });

  testWidgets('CTA is disabled while the title is empty', (tester) async {
    await openForm(tester, _FormHost());

    expect(submitEnabled(tester), isFalse);

    final titleField = find.descendant(
      of: find.byKey(const Key('starnyx-form-title')),
      matching: find.byType(EditableText),
    );
    await tester.enterText(titleField, 'Walk');
    await tester.pump();
    expect(submitEnabled(tester), isTrue);

    await tester.enterText(titleField, '   ');
    await tester.pump();
    expect(submitEnabled(tester), isFalse);
    expect(find.text('Title is required'), findsOneWidget);
  });

  testWidgets('delete asks for confirmation; cancel keeps the habit', (
    tester,
  ) async {
    final habit = _habit();
    await repository.saveStarnyx(habit);
    final host = _FormHost(starnyx: habit);
    await openForm(tester, host);

    await tapVisible(tester, find.byKey(const Key('starnyx-form-delete')));
    expect(find.text('Delete this habit?'), findsOneWidget);
    expect(
      find.textContaining('Gym', findRichText: true),
      findsAtLeastNWidgets(1),
    );

    await tester.tap(find.byKey(const Key('app-confirm-cancel')));
    await tester.pumpAndSettle();

    expect(find.text('Delete this habit?'), findsNothing);
    expect(find.text('Edit habit'), findsOneWidget);
    expect(await repository.getStarnyxById(habit.id), isNotNull);

    await tapVisible(tester, find.byKey(const Key('starnyx-form-delete')));
    await tester.tap(find.byKey(const Key('app-confirm-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('Edit habit'), findsNothing);
    expect(host.result?.deletedStarnyxId, habit.id);
    expect(await repository.getStarnyxById(habit.id), isNull);
  });

  testWidgets('layout holds at 320px and 2.0 text scale', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final habit = _habit();
    await repository.saveStarnyx(habit);
    await openForm(tester, _FormHost(starnyx: habit), tall: false);
    await tester.scrollUntilVisible(
      submit,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}

StarNyx _habit() {
  final today = DateTime.now();
  return StarNyx(
    id: 'habit-1',
    title: 'Gym',
    description: null,
    color: '#10B981',
    startDate: DateTime(today.year, today.month, today.day),
    reminderEnabled: false,
    reminderTime: null,
    createdAt: today,
    updatedAt: today,
  );
}

// ignore: must_be_immutable
class _FormHost extends StatelessWidget {
  _FormHost({this.starnyx});

  final StarNyx? starnyx;
  StarnyxFormResult? result;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        result = await StarnyxFormPage.open(context, starnyx: starnyx);
      },
      child: const Text('open'),
    );
  }
}

void _registerFormTestDependencies(_InMemoryStarNyxRepository repository) {
  final appSettingsRepository = _InMemoryAppSettingsRepository();
  final createUseCase = CreateStarNyxUseCase(repository, const Uuid());
  final updateUseCase = UpdateStarNyxUseCase(repository);
  final deleteUseCase = DeleteStarNyxUseCase(repository, appSettingsRepository);
  final syncUseCase = SyncNotificationsUseCase(
    _FakeNotificationService(),
    repository,
  );

  serviceLocator.registerFactoryParam<StarnyxFormBloc, StarNyx?, String?>((
    initialStarnyx,
    initialColor,
  ) {
    return StarnyxFormBloc(
      createStarNyxUseCase: createUseCase,
      updateStarNyxUseCase: updateUseCase,
      deleteStarNyxUseCase: deleteUseCase,
      syncNotificationsUseCase: syncUseCase,
      initialStarnyx: initialStarnyx,
      initialColor: initialColor,
    );
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
          home: Scaffold(body: Center(child: child)),
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
  Future<void> reorderStarnyxs(List<String> orderedIds) async {}

  @override
  Stream<List<StarNyx>> watchAllStarnyxs() async* {
    yield await getAllStarnyxs();
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

class _FakeNotificationService implements NotificationService {
  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<bool> hasPermission() async => true;

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

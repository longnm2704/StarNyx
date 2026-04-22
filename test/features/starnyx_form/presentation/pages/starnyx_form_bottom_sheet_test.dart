import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:starnyx/core/services/core_services.dart';
import 'package:starnyx/domain/entities/domain_entities.dart';
import 'package:starnyx/domain/repositories/domain_repositories.dart';
import 'package:starnyx/domain/usecases/domain_usecases.dart';
import 'package:starnyx/features/starnyx_form/presentation/bloc/starnyx_form_bloc.dart';
import 'package:starnyx/features/starnyx_form/presentation/pages/create_starnyx_bottom_sheet.dart';

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
    'create starnyx bottom sheet surfaces title required validation',
    (tester) async {
      _registerFormTestDependencies();

      await tester.pumpWidget(_buildLocalizedApp(const _AutoOpenFormHost()));
      await tester.pumpAndSettle();

      expect(find.text('New Constellation'), findsOneWidget);
      expect(find.text('Save Constellation'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Save Constellation'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      await tester.tap(find.text('Save Constellation'));
      await tester.pump();

      expect(find.text('Title is required'), findsOneWidget);
    },
  );

  testWidgets(
    'create starnyx bottom sheet remains scrollable on small screens',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      _registerFormTestDependencies();

      await tester.pumpWidget(_buildLocalizedApp(const _AutoOpenFormHost()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    },
  );
}

class _AutoOpenFormHost extends StatefulWidget {
  const _AutoOpenFormHost();

  @override
  State<_AutoOpenFormHost> createState() => _AutoOpenFormHostState();
}

class _AutoOpenFormHostState extends State<_AutoOpenFormHost> {
  bool _didOpen = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didOpen) {
      return;
    }
    _didOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        showCreateStarnyxBottomSheet(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

void _registerFormTestDependencies() {
  final inMemoryRepository = _InMemoryStarNyxRepository();
  final appSettingsRepository = _InMemoryAppSettingsRepository();
  final createUseCase = CreateStarNyxUseCase(inMemoryRepository, const Uuid());
  final updateUseCase = UpdateStarNyxUseCase(inMemoryRepository);
  final deleteUseCase = DeleteStarNyxUseCase(
    inMemoryRepository,
    appSettingsRepository,
  );
  final syncUseCase = SyncNotificationsUseCase(
    _FakeNotificationService(),
    inMemoryRepository,
  );

  serviceLocator.registerFactoryParam<StarnyxFormBloc, StarNyx?, void>((
    initialStarnyx,
    _,
  ) {
    return StarnyxFormBloc(
      createStarNyxUseCase: createUseCase,
      updateStarNyxUseCase: updateUseCase,
      deleteStarNyxUseCase: deleteUseCase,
      syncNotificationsUseCase: syncUseCase,
      initialStarnyx: initialStarnyx,
      nowBuilder: () => DateTime(2026, 4, 13, 10, 20),
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
  Future<void> initialize() async {}

  @override
  Future<void> createReminder(StarNyx starnyx) async {}

  @override
  Future<void> updateReminder(StarNyx starnyx) async {}

  @override
  Future<void> cancelReminder(String starnyxId) async {}

  @override
  Future<void> cancelAllReminders() async {}
}

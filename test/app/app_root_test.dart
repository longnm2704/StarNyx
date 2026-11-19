import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starnyx/app/app_root.dart';
import 'package:starnyx/app/di/service_locator.dart';
import 'package:starnyx/app/shell/app_shell.dart';
import 'package:starnyx/app/theme/app_theme.dart';
import 'package:starnyx/core/services/core_services.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/repositories/starnyx_repository.dart';
import 'package:starnyx/domain/usecases/domain_usecases.dart';
import 'package:starnyx/features/onboarding/presentation/onboarding_flow.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeStarNyxRepository repository;
  late OnboardingPreferences onboarding;
  late SharedPreferences preferences;

  setUp(() async {
    rootBundle.clear();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
    preferences = await SharedPreferences.getInstance();
    repository = _FakeStarNyxRepository();
    onboarding = OnboardingPreferences(preferences);
    serviceLocator
      ..registerSingleton<OnboardingPreferences>(onboarding)
      ..registerSingleton<LoadStarnyxsUseCase>(LoadStarnyxsUseCase(repository));
  });

  tearDown(serviceLocator.reset);

  Future<void> render(WidgetTester tester) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const <Locale>[Locale('en')],
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        path: 'assets/translations',
        useOnlyLangCode: true,
        child: Builder(
          builder: (context) => MaterialApp(
            theme: AppTheme.dark(),
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            home: AppRoot(
              tabs: <Widget>[
                for (final tab in AppShellTab.values) Text('tab-${tab.name}'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('fresh install shows onboarding', (tester) async {
    await render(tester);

    expect(find.byType(OnboardingFlow), findsOneWidget);
    expect(find.byType(AppShell), findsNothing);
  });

  testWidgets('leaving onboarding lands on Habits and is remembered', (
    tester,
  ) async {
    await render(tester);

    await tester.tap(find.byKey(const Key('onboarding-skip')));
    await tester.pumpAndSettle();

    expect(find.byType(AppShell), findsOneWidget);
    expect(find.text('tab-habits'), findsOneWidget);
    expect(onboarding.completed, isTrue);

    // Next launch, still no habits: straight to the app.
    await tester.pumpWidget(const SizedBox());
    await render(tester);
    expect(find.byType(AppShell), findsOneWidget);
  });

  testWidgets('existing habits skip onboarding and set the flag', (
    tester,
  ) async {
    repository.items.add(_habit());

    await render(tester);

    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byType(OnboardingFlow), findsNothing);
    expect(onboarding.completed, isTrue);
  });

  testWidgets('delete-all routes back to onboarding', (tester) async {
    repository.items.add(_habit());
    await render(tester);
    expect(find.byType(AppShell), findsOneWidget);

    await tester.runAsync(
      () => DeleteAllDataUseCase(
        () async => repository.items.clear(),
        SyncNotificationsUseCase(_FakeNotificationService(), repository),
        ActiveStarnyxColorCache(preferences),
        onboarding,
      ).call(),
    );
    tester.widget<AppShell>(find.byType(AppShell)).onDataReplaced!();
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingFlow), findsOneWidget);
    expect(onboarding.completed, isFalse);
  });
}

StarNyx _habit() => StarNyx(
  id: 'a',
  title: 'Water',
  description: null,
  color: '#10B981',
  startDate: DateTime(2026, 11, 1),
  reminderEnabled: false,
  reminderTime: null,
  createdAt: DateTime(2026, 11, 1),
  updatedAt: DateTime(2026, 11, 1),
);

class _FakeStarNyxRepository implements StarNyxRepository {
  final items = <StarNyx>[];

  @override
  Future<List<StarNyx>> getAllStarnyxs() async => List.of(items);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeNotificationService implements NotificationService {
  @override
  Future<void> cancelAllReminders() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

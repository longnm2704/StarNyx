import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/entities/starnyx_progress_stats.dart';
import 'package:starnyx/domain/entities/storage_stats.dart';
import 'package:starnyx/domain/usecases/domain_usecases.dart';
import 'package:starnyx/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:starnyx/features/settings/presentation/pages/settings_page.dart';

class _MockExport extends Mock implements ExportDataUseCase {}

class _MockImport extends Mock implements ImportDataUseCase {}

class _MockSync extends Mock implements SyncNotificationsUseCase {}

class _MockLoadAll extends Mock implements LoadStarnyxsUseCase {}

class _MockLoadActive extends Mock implements LoadActiveStarNyxUseCase {}

class _MockStats extends Mock implements LoadStarNyxProgressStatsUseCase {}

class _MockSetReminders extends Mock implements SetAllRemindersEnabledUseCase {}

class _MockDeleteAll extends Mock implements DeleteAllDataUseCase {}

final _habit = StarNyx(
  id: 'habit-1',
  title: 'Uống nước',
  description: null,
  color: '#10B981',
  startDate: DateTime(2026, 6, 1),
  reminderEnabled: true,
  reminderTime: '21:00',
  createdAt: DateTime(2026, 6, 1),
  updatedAt: DateTime(2026, 6, 1),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockSetReminders setReminders;
  // Built inside each test body so bloc streams run in the fake-async zone.
  late SettingsBloc Function() makeBloc;

  setUp(() async {
    rootBundle.clear();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    PackageInfo.setMockInitialValues(
      appName: 'StarNyx',
      packageName: 'app.starnyx',
      version: '1.2.3',
      buildNumber: '45',
      buildSignature: '',
    );
    await EasyLocalization.ensureInitialized();

    final loadAll = _MockLoadAll();
    final loadActive = _MockLoadActive();
    final stats = _MockStats();
    setReminders = _MockSetReminders();
    when(loadAll.call).thenAnswer((_) async => <StarNyx>[_habit]);
    when(
      () => loadActive.call(now: any(named: 'now')),
    ).thenAnswer((_) async => _habit);
    when(
      () => stats.call(
        starnyxId: any(named: 'starnyxId'),
        year: any(named: 'year'),
        today: any(named: 'today'),
      ),
    ).thenAnswer(
      (_) async => const StarNyxProgressStats(
        currentStreak: 7,
        longestStreak: 7,
        totalCompletedCount: 7,
        completedCountForYear: 7,
        validDayCountForYear: 10,
        completionRateForYear: 0.7,
      ),
    );
    when(() => setReminders.call(any())).thenAnswer((_) async {});

    makeBloc = () => SettingsBloc(
      exportDataUseCase: _MockExport(),
      importDataUseCase: _MockImport(),
      syncNotificationsUseCase: _MockSync(),
      loadStarnyxsUseCase: loadAll,
      loadActiveStarNyxUseCase: loadActive,
      loadStarNyxProgressStatsUseCase: stats,
      setAllRemindersEnabledUseCase: setReminders,
      deleteAllDataUseCase: _MockDeleteAll(),
      loadStorageStats: () async => const StorageStats(
        bytes: 0,
        habitCount: 1,
        completionCount: 0,
        journalCount: 0,
      ),
    );
  });

  testWidgets('renders live summary and version', (tester) async {
    await _render(tester, makeBloc());

    expect(find.text('Cài đặt'), findsOneWidget);
    expect(find.text('Uống nước'), findsOneWidget);
    expect(find.text('Chuỗi thói quen: 7 ngày liên tục'), findsOneWidget);
    expect(find.text('Nhắc nhở tiếp theo lúc 21:00'), findsOneWidget);
    expect(find.text('Tiếng Việt'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('1.2.3 (45)'), 200);
    expect(find.text('1.2.3 (45)'), findsOneWidget);
  });

  testWidgets('fits a 320pt screen at 2x text without overflow', (
    tester,
  ) async {
    // Regression for STX-U026: trailing values used to squeeze row titles.
    tester.view.physicalSize = const Size(320, 3600);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await _render(tester, makeBloc());

    expect(find.text('Ngôn ngữ'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('language row opens the language picker', (tester) async {
    await _render(tester, makeBloc());

    await tester.tap(find.byKey(const Key('settings-language-row')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('settings-language-picker')), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('日本語'), findsOneWidget);
  });

  testWidgets('reminder switch turns all reminders off', (tester) async {
    await _render(tester, makeBloc());

    await tester.tap(find.byKey(const Key('settings-reminders-switch')));
    await tester.pumpAndSettle();

    verify(() => setReminders.call(false)).called(1);
  });
}

Future<void> _render(WidgetTester tester, SettingsBloc bloc) async {
  addTearDown(bloc.close);
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const <Locale>[
        Locale('vi'),
        Locale('en'),
        Locale('ja'),
      ],
      fallbackLocale: const Locale('vi'),
      startLocale: const Locale('vi'),
      path: 'assets/translations',
      useOnlyLangCode: true,
      child: Builder(
        builder: (context) => MaterialApp(
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          home: SettingsPage(bloc: bloc),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

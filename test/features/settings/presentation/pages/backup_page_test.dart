import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starnyx/domain/entities/domain_entities.dart';
import 'package:starnyx/domain/usecases/domain_usecases.dart';
import 'package:starnyx/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:starnyx/features/settings/presentation/pages/backup_page.dart';

class _MockExport extends Mock implements ExportDataUseCase {}

class _MockImport extends Mock implements ImportDataUseCase {}

class _MockSync extends Mock implements SyncNotificationsUseCase {}

class _MockLoadAll extends Mock implements LoadStarnyxsUseCase {}

class _MockLoadActive extends Mock implements LoadActiveStarNyxUseCase {}

class _MockStats extends Mock implements LoadStarNyxProgressStatsUseCase {}

class _MockSetReminders extends Mock implements SetAllRemindersEnabledUseCase {}

class _MockDeleteAll extends Mock implements DeleteAllDataUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockExport export;
  late _MockDeleteAll deleteAll;
  late SettingsBloc Function() makeBloc;

  setUp(() async {
    rootBundle.clear();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();

    export = _MockExport();
    deleteAll = _MockDeleteAll();
    // Failing keeps the page in place (no share sheet, no pop).
    when(export.call).thenThrow(StateError('test'));
    when(deleteAll.call).thenThrow(StateError('test'));

    makeBloc = () => SettingsBloc(
      exportDataUseCase: export,
      importDataUseCase: _MockImport(),
      syncNotificationsUseCase: _MockSync(),
      loadStarnyxsUseCase: _MockLoadAll(),
      loadActiveStarNyxUseCase: _MockLoadActive(),
      loadStarNyxProgressStatsUseCase: _MockStats(),
      setAllRemindersEnabledUseCase: _MockSetReminders(),
      deleteAllDataUseCase: deleteAll,
      loadStorageStats: () async => const StorageStats(
        bytes: 1468006,
        habitCount: 3,
        completionCount: 128,
        journalCount: 42,
      ),
    );
  });

  testWidgets('shows database size and row counts', (tester) async {
    await _render(tester, makeBloc());

    expect(find.text('Backup & Export'), findsOneWidget);
    expect(find.text('1.4 MB'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('128'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
  });

  testWidgets('onboarding restore hides the delete-all zone', (tester) async {
    await _render(tester, makeBloc(), showDangerZone: false);

    expect(find.byKey(const Key('backup-delete-all-button')), findsNothing);
  });

  testWidgets('export button runs passphrase and privacy steps then exports', (
    tester,
  ) async {
    await _render(tester, makeBloc());

    await tester.tap(find.byKey(const Key('backup-export-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Backup privacy warning'), findsOneWidget);
    verifyNever(export.call);

    await tester.tap(find.widgetWithText(FilledButton, 'Export backup'));
    await tester.pump();

    verify(export.call).called(1);
  });

  testWidgets('delete all needs two confirmations', (tester) async {
    await _render(tester, makeBloc());
    final button = find.byKey(const Key('backup-delete-all-button'));

    await tester.scrollUntilVisible(button, 300);
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('Delete all data?'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Are you sure?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    verifyNever(deleteAll.call);

    await tester.tap(button);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete permanently'));
    await tester.pump();

    verify(deleteAll.call).called(1);
  });
}

Future<void> _render(
  WidgetTester tester,
  SettingsBloc bloc, {
  bool showDangerZone = true,
}) async {
  addTearDown(bloc.close);
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const <Locale>[Locale('en')],
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      path: 'assets/translations',
      useOnlyLangCode: true,
      child: Builder(
        builder: (context) => MaterialApp(
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          home: Scaffold(
            body: BlocProvider<SettingsBloc>.value(
              value: bloc,
              child: BackupPage(onBack: () {}, showDangerZone: showDangerZone),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

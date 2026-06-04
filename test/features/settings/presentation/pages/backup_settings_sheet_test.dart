import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starnyx/core/services/core_services.dart';
import 'package:starnyx/domain/entities/domain_entities.dart';
import 'package:starnyx/domain/repositories/domain_repositories.dart';
import 'package:starnyx/domain/usecases/domain_usecases.dart';
import 'package:starnyx/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:starnyx/features/settings/presentation/pages/backup_settings_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets(
    'export shows privacy warning before starting an unencrypted backup',
    (tester) async {
      final exportStarted = Completer<void>();
      final releaseExport = Completer<void>();
      final tempDirectory = Directory.systemTemp.createTempSync(
        'starnyx-backup-settings-sheet-test-',
      );
      final bloc = _buildSettingsBloc(
        starNyxRepository: _BlockingStarNyxRepository(
          exportStarted: exportStarted,
          releaseExport: releaseExport,
        ),
        tempDirectory: tempDirectory,
      );

      addTearDown(() async {
        if (!releaseExport.isCompleted) {
          releaseExport.complete();
        }
        await bloc.close();
        if (tempDirectory.existsSync()) {
          tempDirectory.deleteSync(recursive: true);
        }
      });

      await tester.pumpWidget(_buildLocalizedApp(bloc));
      await tester.pump();

      await tester.tap(find.text('Export backup'));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(find.text('Backup privacy warning'), findsOneWidget);
      expect(
        find.textContaining('may contain sensitive journal and habit data'),
        findsOneWidget,
      );
      expect(
        find.textContaining('even when you export without a passphrase'),
        findsOneWidget,
      );
      expect(exportStarted.isCompleted, isFalse);

      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(exportStarted.isCompleted, isFalse);
    },
  );
}

SettingsBloc _buildSettingsBloc({
  required StarNyxRepository starNyxRepository,
  required Directory tempDirectory,
}) {
  final completionRepository = _EmptyCompletionRepository();
  final journalEntryRepository = _EmptyJournalEntryRepository();
  final appSettingsRepository = _EmptyAppSettingsRepository();

  return SettingsBloc(
    exportDataUseCase: ExportDataUseCase(
      starNyxRepository,
      completionRepository,
      journalEntryRepository,
      appSettingsRepository,
    ),
    importDataUseCase: ImportDataUseCase(
      starNyxRepository,
      completionRepository,
      journalEntryRepository,
      appSettingsRepository,
    ),
    syncNotificationsUseCase: SyncNotificationsUseCase(
      _NoOpNotificationService(),
      starNyxRepository,
    ),
    tempDirectoryProvider: () async => tempDirectory,
  );
}

Widget _buildLocalizedApp(SettingsBloc bloc) {
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
          home: Scaffold(
            body: BlocProvider<SettingsBloc>.value(
              value: bloc,
              child: const BackupSettingsSheet(onBack: _noop),
            ),
          ),
        );
      },
    ),
  );
}

void _noop() {}

class _BlockingStarNyxRepository implements StarNyxRepository {
  _BlockingStarNyxRepository({
    required this.exportStarted,
    required this.releaseExport,
  });

  final Completer<void> exportStarted;
  final Completer<void> releaseExport;

  @override
  Future<void> deleteStarnyxById(String id) async {}

  @override
  Future<List<StarNyx>> getAllStarnyxs() async {
    if (!exportStarted.isCompleted) {
      exportStarted.complete();
    }
    await releaseExport.future;
    return <StarNyx>[];
  }

  @override
  Future<StarNyx?> getStarnyxById(String id) async => null;

  @override
  Future<void> saveStarnyx(StarNyx starnyx) async {}

  @override
  Future<void> reorderStarnyxs(List<String> orderedIds) async {}

  @override
  Stream<List<StarNyx>> watchAllStarnyxs() => Stream.value(<StarNyx>[]);
}

class _EmptyCompletionRepository implements CompletionRepository {
  @override
  Future<void> deleteCompletionByDate({
    required String starnyxId,
    required DateTime date,
  }) async {}

  @override
  Future<void> deleteCompletionsForStarnyx(String starnyxId) async {}

  @override
  Future<Completion?> getCompletionByDate({
    required String starnyxId,
    required DateTime date,
  }) async {
    return null;
  }

  @override
  Future<List<Completion>> getCompletionsForStarnyx(String starnyxId) async {
    return <Completion>[];
  }

  @override
  Future<void> saveCompletion(Completion completion) async {}

  @override
  Stream<List<Completion>> watchCompletionsForStarnyx(String starnyxId) {
    return Stream.value(<Completion>[]);
  }
}

class _EmptyJournalEntryRepository implements JournalEntryRepository {
  @override
  Future<void> deleteJournalEntriesForStarnyx(String starnyxId) async {}

  @override
  Future<void> deleteJournalEntryById(int id) async {}

  @override
  Future<List<JournalEntry>> getJournalEntriesForDate({
    required String starnyxId,
    required DateTime date,
  }) async {
    return <JournalEntry>[];
  }

  @override
  Future<List<JournalEntry>> getJournalEntriesForStarnyx(
    String starnyxId,
  ) async {
    return <JournalEntry>[];
  }

  @override
  Future<void> saveJournalEntry(JournalEntry entry) async {}

  @override
  Stream<List<JournalEntry>> watchJournalEntriesForStarnyx(String starnyxId) {
    return Stream.value(<JournalEntry>[]);
  }
}

class _EmptyAppSettingsRepository implements AppSettingsRepository {
  @override
  Future<AppSettings?> getAppSettings() async => null;

  @override
  Future<void> saveAppSettings(AppSettings settings) async {}

  @override
  Stream<AppSettings?> watchAppSettings() => Stream.value(null);
}

class _NoOpNotificationService implements NotificationService {
  @override
  Future<void> cancelAllReminders() async {}

  @override
  Future<void> cancelReminder(String starnyxId) async {}

  @override
  Future<void> createReminder(StarNyx starnyx) async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> updateReminder(StarNyx starnyx) async {}
}

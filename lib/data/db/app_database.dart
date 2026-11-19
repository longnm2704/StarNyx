import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:starnyx/data/db/starnyx_schema.dart';
import 'package:starnyx/domain/entities/storage_stats.dart';

part 'starnyxs_dao.dart';
part 'app_database.g.dart';
part 'completions_dao.dart';
part 'app_settings_dao.dart';
part 'journal_entries_dao.dart';

// Central Drift database entrypoint for the offline MVP.
@DriftDatabase(
  tables: <Type>[StarNyxs, Completions, JournalEntries, AppSettings],
  daos: <Type>[StarnyxsDao, CompletionsDao, JournalEntriesDao, AppSettingsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  // Schema version 5: Adds journal metadata (mood, energy, sleep, tags).
  int get schemaVersion => 5;

  @override
  // Versioned migrations handle structural changes between schema releases.
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (Migrator migrator, int from, int to) async {
      if (from < 2) {
        // Drop and recreate journal_entries due to primary key and structural changes.
        await migrator.deleteTable('journal_entries');
        await migrator.createTable(journalEntries);
      }
      if (from < 3) {
        await migrator.addColumn(starNyxs, starNyxs.displayOrder);
        await customStatement('''
          UPDATE starnyxs
          SET display_order = (
            SELECT COUNT(*)
            FROM starnyxs AS ranked
            WHERE ranked.updated_at > starnyxs.updated_at
              OR (
                ranked.updated_at = starnyxs.updated_at
                AND ranked.id < starnyxs.id
              )
          )
        ''');
      }
      if (from < 4) {
        await migrator.addColumn(starNyxs, starNyxs.icon);
      }
      // from < 2 recreated journal_entries above with the v5 columns already.
      if (from >= 2 && from < 5) {
        await migrator.addColumn(journalEntries, journalEntries.mood);
        await migrator.addColumn(journalEntries, journalEntries.energy);
        await migrator.addColumn(journalEntries, journalEntries.sleepMinutes);
        await migrator.addColumn(journalEntries, journalEntries.tags);
      }
    },
    beforeOpen: (OpeningDetails details) async {
      // Foreign keys stay enabled so cascade and set-null rules are enforced.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Wipes every user table in one transaction and leaves a single empty
  /// app_settings row behind (used by DeleteAllDataUseCase).
  Future<void> clearAll({DateTime? now}) {
    return transaction(() async {
      await delete(completions).go();
      await delete(journalEntries).go();
      await delete(starNyxs).go();
      await delete(appSettings).go();
      await into(
        appSettings,
      ).insert(AppSettingsCompanion.insert(updatedAt: now ?? DateTime.now()));
    });
  }

  /// Size of the SQLite file plus row counts for the backup screen.
  Future<StorageStats> loadStorageStats() async {
    final row = await customSelect(
      'SELECT (SELECT COUNT(*) FROM starnyxs) AS habits, '
      '(SELECT COUNT(*) FROM completions) AS completions, '
      '(SELECT COUNT(*) FROM journal_entries) AS journals',
    ).getSingle();
    final file = await appDatabaseFile();
    return StorageStats(
      bytes: await file.exists() ? await file.length() : 0,
      habitCount: row.read<int>('habits'),
      completionCount: row.read<int>('completions'),
      journalCount: row.read<int>('journals'),
    );
  }
}

/// Location of the app's SQLite file.
Future<File> appDatabaseFile() async {
  final appDirectory = await getApplicationDocumentsDirectory();
  return File('${appDirectory.path}/starnyx.sqlite');
}

// Drift opens the SQLite file lazily so startup work stays lightweight.
LazyDatabase _openConnection() {
  return LazyDatabase(
    () async => NativeDatabase.createInBackground(await appDatabaseFile()),
  );
}

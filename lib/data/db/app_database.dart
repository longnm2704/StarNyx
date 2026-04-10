import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:starnyx/data/db/starnyx_schema.dart';

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
  // Schema version 1 matches the first persisted MVP database shape.
  int get schemaVersion => 1;

  @override
  // Versioned migrations start here even though v1 only needs table creation.
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (Migrator migrator, int from, int to) async {},
    beforeOpen: (OpeningDetails details) async {
      // Foreign keys stay enabled so cascade and set-null rules are enforced.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

// Drift opens the SQLite file lazily so startup work stays lightweight.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final appDirectory = await getApplicationDocumentsDirectory();
    final databaseFile = File('${appDirectory.path}/starnyx.sqlite');

    return NativeDatabase.createInBackground(databaseFile);
  });
}

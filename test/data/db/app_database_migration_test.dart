import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:starnyx/data/db/app_database.dart';

void main() {
  test('migrates v2 StarNyx rows to deterministic display order', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'starnyx_migration_test_',
    );
    addTearDown(() async {
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });
    final databaseFile = File('${tempDirectory.path}/starnyx.sqlite');
    _createVersion2Database(databaseFile);

    final database = AppDatabase(NativeDatabase(databaseFile));
    addTearDown(database.close);

    final migrated = await database.starnyxsDao.getAllStarnyxs();

    expect(database.schemaVersion, 4);
    expect(migrated.map((item) => item.id), <String>[
      'newest',
      'middle',
      'oldest',
    ]);
    expect(migrated.map((item) => item.displayOrder), <int>[0, 1, 2]);
  });

  test('migrates v3 StarNyx rows to icon defaulting to star', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'starnyx_migration_v4_test_',
    );
    addTearDown(() async {
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });
    final databaseFile = File('${tempDirectory.path}/starnyx.sqlite');
    _createVersion3Database(databaseFile);

    final database = AppDatabase(NativeDatabase(databaseFile));
    addTearDown(database.close);

    final migrated = await database.starnyxsDao.getAllStarnyxs();

    expect(database.schemaVersion, 4);
    expect(migrated.map((item) => item.icon), <String>['star', 'star', 'star']);
    expect(
      migrated.map((item) => item.id),
      <String>['oldest', 'newest', 'middle'],
    );
  });
}

void _createVersion2Database(File databaseFile) {
  final db = sqlite.sqlite3.open(databaseFile.path);
  try {
    db.execute('''
      CREATE TABLE starnyxs (
        id TEXT NOT NULL PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NULL,
        color TEXT NOT NULL,
        start_date TEXT NOT NULL,
        reminder_enabled INTEGER NOT NULL DEFAULT 0,
        reminder_time TEXT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      );
    ''');
    db.execute('''
      INSERT INTO starnyxs (
        id, title, description, color, start_date, reminder_enabled,
        reminder_time, created_at, updated_at
      ) VALUES
        ('oldest', 'Oldest', NULL, '#102030', '2026-04-01', 0, NULL, 0, 1000),
        ('newest', 'Newest', NULL, '#102030', '2026-04-01', 0, NULL, 0, 3000),
        ('middle', 'Middle', NULL, '#102030', '2026-04-01', 0, NULL, 0, 2000);
    ''');
    db.execute('PRAGMA user_version = 2;');
  } finally {
    db.close();
  }
}

void _createVersion3Database(File databaseFile) {
  final db = sqlite.sqlite3.open(databaseFile.path);
  try {
    db.execute('''
      CREATE TABLE starnyxs (
        id TEXT NOT NULL PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NULL,
        color TEXT NOT NULL,
        start_date TEXT NOT NULL,
        reminder_enabled INTEGER NOT NULL DEFAULT 0,
        reminder_time TEXT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        display_order INTEGER NOT NULL DEFAULT 0
      );
    ''');
    db.execute('''
      INSERT INTO starnyxs (
        id, title, description, color, start_date, reminder_enabled,
        reminder_time, created_at, updated_at, display_order
      ) VALUES
        ('oldest', 'Oldest', NULL, '#102030', '2026-04-01', 0, NULL, 1000, 3000, 0),
        ('newest', 'Newest', NULL, '#102030', '2026-04-01', 0, NULL, 3000, 1000, 1),
        ('middle', 'Middle', NULL, '#102030', '2026-04-01', 0, NULL, 2000, 2000, 2);
    ''');
    db.execute('PRAGMA user_version = 3;');
  } finally {
    db.close();
  }
}

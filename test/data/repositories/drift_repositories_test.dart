import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/data/db/app_database.dart';
import 'package:starnyx/data/repositories/data_repositories.dart';
import 'package:starnyx/domain/entities/domain_entities.dart' as domain;

// Verifies Drift repositories map correctly between SQLite rows and domain objects.
void main() {
  late AppDatabase database;
  late DriftStarNyxRepository starNyxRepository;
  late DriftCompletionRepository completionRepository;
  late DriftJournalEntryRepository journalEntryRepository;
  late DriftAppSettingsRepository appSettingsRepository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    starNyxRepository = DriftStarNyxRepository(database);
    completionRepository = DriftCompletionRepository(database);
    journalEntryRepository = DriftJournalEntryRepository(database);
    appSettingsRepository = DriftAppSettingsRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('saves and loads StarNyx domain entities', () async {
    final entity = domain.StarNyx(
      id: 'habit-1',
      title: 'Hydrate',
      description: 'Drink enough water',
      color: '#102030',
      startDate: DateTime(2026, 4, 1),
      reminderEnabled: true,
      reminderTime: '09:30',
      createdAt: DateTime(2026, 4, 1, 8),
      updatedAt: DateTime(2026, 4, 2, 9),
    );

    await starNyxRepository.saveStarnyx(entity);

    final saved = await starNyxRepository.getStarnyxById('habit-1');

    expect(saved, equals(entity));
  });

  test('saves and loads completion domain entities by date', () async {
    await starNyxRepository.saveStarnyx(
      domain.StarNyx(
        id: 'habit-1',
        title: 'Hydrate',
        description: null,
        color: '#102030',
        startDate: DateTime(2026, 4, 1),
        reminderEnabled: false,
        reminderTime: null,
        createdAt: DateTime(2026, 4, 1, 8),
        updatedAt: DateTime(2026, 4, 2, 9),
      ),
    );

    final entity = domain.Completion(
      starnyxId: 'habit-1',
      date: DateTime(2026, 4, 10),
      completed: true,
    );

    await completionRepository.saveCompletion(entity);

    final saved = await completionRepository.getCompletionByDate(
      starnyxId: 'habit-1',
      date: DateTime(2026, 4, 10),
    );

    expect(saved, equals(entity));
  });

  test('saves and loads journal entry domain entities by date', () async {
    await starNyxRepository.saveStarnyx(
      domain.StarNyx(
        id: 'habit-1',
        title: 'Hydrate',
        description: null,
        color: '#102030',
        startDate: DateTime(2026, 4, 1),
        reminderEnabled: false,
        reminderTime: null,
        createdAt: DateTime(2026, 4, 1, 8),
        updatedAt: DateTime(2026, 4, 2, 9),
      ),
    );

    final entry = domain.JournalEntry(
      starnyxId: 'habit-1',
      date: DateTime(2026, 4, 10),
      content: 'Stayed consistent today.',
    );

    await journalEntryRepository.saveJournalEntry(entry);

    final saved = await journalEntryRepository.getJournalEntryByDate(
      starnyxId: 'habit-1',
      date: DateTime(2026, 4, 10),
    );

    expect(saved, equals(entry));
  });

  test('saves and loads app settings domain entities', () async {
    await starNyxRepository.saveStarnyx(
      domain.StarNyx(
        id: 'habit-1',
        title: 'Hydrate',
        description: null,
        color: '#102030',
        startDate: DateTime(2026, 4, 1),
        reminderEnabled: false,
        reminderTime: null,
        createdAt: DateTime(2026, 4, 1, 8),
        updatedAt: DateTime(2026, 4, 2, 9),
      ),
    );

    final settings = domain.AppSettings(
      lastSelectedStarnyxId: 'habit-1',
      updatedAt: DateTime(2026, 4, 10, 8, 30),
    );

    await appSettingsRepository.saveAppSettings(settings);

    final saved = await appSettingsRepository.getAppSettings();

    expect(saved, equals(settings));
  });
}

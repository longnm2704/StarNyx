import 'package:uuid/uuid.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/domain/entities/domain_entities.dart';
import 'package:starnyx/domain/usecases/domain_usecases.dart';
import 'package:starnyx/domain/repositories/domain_repositories.dart';

// Covers the core orchestration behavior expected from phase-1 use cases.
void main() {
  late _InMemoryStarNyxRepository starNyxRepository;
  late _InMemoryCompletionRepository completionRepository;
  late _InMemoryJournalEntryRepository journalEntryRepository;
  late _InMemoryAppSettingsRepository appSettingsRepository;

  setUp(() {
    starNyxRepository = _InMemoryStarNyxRepository();
    completionRepository = _InMemoryCompletionRepository();
    journalEntryRepository = _InMemoryJournalEntryRepository();
    appSettingsRepository = _InMemoryAppSettingsRepository();
  });

  test('create use case generates and saves a StarNyx', () async {
    final useCase = CreateStarNyxUseCase(starNyxRepository, const Uuid());
    final now = DateTime(2026, 4, 10, 8, 30);

    final created = await useCase(
      title: 'Hydrate',
      description: 'Drink enough water',
      color: '#102030',
      startDate: DateTime(2026, 4, 10, 21, 5),
      reminderEnabled: true,
      reminderTime: '09:30',
      now: now,
    );

    expect(created.id, isNotEmpty);
    expect(created.startDate, DateTime(2026, 4, 10));
    expect(created.createdAt, now);
    expect(created.updatedAt, now);
    expect(await starNyxRepository.getStarnyxById(created.id), created);
  });

  test('create use case rejects a future start date', () async {
    final useCase = CreateStarNyxUseCase(starNyxRepository, const Uuid());

    expect(
      () => useCase(
        title: 'Hydrate',
        description: null,
        color: '#102030',
        startDate: DateTime(2026, 4, 11),
        reminderEnabled: false,
        reminderTime: null,
        now: DateTime(2026, 4, 10, 8, 30),
      ),
      throwsA(
        isA<UseCaseValidationException>().having(
          (error) => error.code,
          'code',
          UseCaseValidationCode.startDateInFuture,
        ),
      ),
    );
  });

  test('create use case rejects start dates older than 7 days', () async {
    final useCase = CreateStarNyxUseCase(starNyxRepository, const Uuid());

    expect(
      () => useCase(
        title: 'Hydrate',
        description: null,
        color: '#102030',
        startDate: DateTime(2026, 4, 5),
        reminderEnabled: false,
        reminderTime: null,
        now: DateTime(2026, 4, 13, 8, 30),
      ),
      throwsA(
        isA<UseCaseValidationException>().having(
          (error) => error.code,
          'code',
          UseCaseValidationCode.startDateTooFarInPast,
        ),
      ),
    );
  });

  test(
    'create use case clears reminder time when reminder is disabled',
    () async {
      final useCase = CreateStarNyxUseCase(starNyxRepository, const Uuid());

      final created = await useCase(
        title: 'Hydrate',
        description: null,
        color: '#102030',
        startDate: DateTime(2026, 4, 10),
        reminderEnabled: false,
        reminderTime: '09:30',
        now: DateTime(2026, 4, 10, 8, 30),
      );

      expect(created.reminderEnabled, isFalse);
      expect(created.reminderTime, isNull);
    },
  );

  test('update use case rejects a future start date', () async {
    final useCase = UpdateStarNyxUseCase(starNyxRepository);
    final starnyx = StarNyx(
      id: 'habit-1',
      title: 'Hydrate',
      description: null,
      color: '#102030',
      startDate: DateTime(2026, 4, 11),
      reminderEnabled: false,
      reminderTime: null,
      createdAt: DateTime(2026, 4, 1, 8),
      updatedAt: DateTime(2026, 4, 1, 8),
    );

    expect(
      () => useCase(starnyx, now: DateTime(2026, 4, 10, 8, 30)),
      throwsA(
        isA<UseCaseValidationException>().having(
          (error) => error.code,
          'code',
          UseCaseValidationCode.startDateInFuture,
        ),
      ),
    );
  });

  test('update use case rejects start dates older than 7 days', () async {
    final useCase = UpdateStarNyxUseCase(starNyxRepository);
    final starnyx = StarNyx(
      id: 'habit-1',
      title: 'Hydrate',
      description: null,
      color: '#102030',
      startDate: DateTime(2026, 4, 5),
      reminderEnabled: false,
      reminderTime: null,
      createdAt: DateTime(2026, 4, 1, 8),
      updatedAt: DateTime(2026, 4, 1, 8),
    );

    expect(
      () => useCase(starnyx, now: DateTime(2026, 4, 13, 8, 30)),
      throwsA(
        isA<UseCaseValidationException>().having(
          (error) => error.code,
          'code',
          UseCaseValidationCode.startDateTooFarInPast,
        ),
      ),
    );
  });

  test(
    'update use case clears reminder time when reminder is disabled',
    () async {
      final useCase = UpdateStarNyxUseCase(starNyxRepository);
      final starnyx = StarNyx(
        id: 'habit-1',
        title: 'Hydrate',
        description: null,
        color: '#102030',
        startDate: DateTime(2026, 4, 10),
        reminderEnabled: false,
        reminderTime: '09:30',
        createdAt: DateTime(2026, 4, 1, 8),
        updatedAt: DateTime(2026, 4, 1, 8),
      );

      final updated = await useCase(starnyx, now: DateTime(2026, 4, 10, 8, 30));

      expect(updated.reminderEnabled, isFalse);
      expect(updated.reminderTime, isNull);
    },
  );

  test(
    'load active use case falls back to the first StarNyx and repairs settings',
    () async {
      final first = StarNyx(
        id: 'habit-1',
        title: 'Hydrate',
        description: null,
        color: '#102030',
        startDate: DateTime(2026, 4, 1),
        reminderEnabled: false,
        reminderTime: null,
        createdAt: DateTime(2026, 4, 1, 8),
        updatedAt: DateTime(2026, 4, 2, 9),
      );
      final second = first.copyWith(id: 'habit-2', title: 'Read');

      await starNyxRepository.saveStarnyx(first);
      await starNyxRepository.saveStarnyx(second);
      await appSettingsRepository.saveAppSettings(
        AppSettings(
          lastSelectedStarnyxId: 'missing-id',
          updatedAt: DateTime(2026, 4, 5, 9),
        ),
      );

      final useCase = LoadActiveStarNyxUseCase(
        starNyxRepository,
        appSettingsRepository,
      );
      final active = await useCase(now: DateTime(2026, 4, 10, 8));

      expect(active, first);
      expect(
        (await appSettingsRepository.getAppSettings())?.lastSelectedStarnyxId,
        'habit-1',
      );
    },
  );

  test(
    'delete use case removes the selected StarNyx and clears invalid selection',
    () async {
      await starNyxRepository.saveStarnyx(
        StarNyx(
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
      await appSettingsRepository.saveAppSettings(
        AppSettings(
          lastSelectedStarnyxId: 'habit-1',
          updatedAt: DateTime(2026, 4, 10, 8),
        ),
      );

      final useCase = DeleteStarNyxUseCase(
        starNyxRepository,
        appSettingsRepository,
      );

      await useCase('habit-1', now: DateTime(2026, 4, 13, 8, 30));

      expect(await starNyxRepository.getStarnyxById('habit-1'), isNull);
      expect(
        (await appSettingsRepository.getAppSettings())?.lastSelectedStarnyxId,
        isNull,
      );
    },
  );

  test(
    'delete use case falls back to another StarNyx when selected item is removed',
    () async {
      final first = StarNyx(
        id: 'habit-1',
        title: 'Hydrate',
        description: null,
        color: '#102030',
        startDate: DateTime(2026, 4, 1),
        reminderEnabled: false,
        reminderTime: null,
        createdAt: DateTime(2026, 4, 1, 8),
        updatedAt: DateTime(2026, 4, 4, 9),
      );
      final second = first.copyWith(
        id: 'habit-2',
        title: 'Read',
        updatedAt: DateTime(2026, 4, 3, 9),
      );
      await starNyxRepository.saveStarnyx(first);
      await starNyxRepository.saveStarnyx(second);
      await appSettingsRepository.saveAppSettings(
        AppSettings(
          lastSelectedStarnyxId: 'habit-1',
          updatedAt: DateTime(2026, 4, 10, 8),
        ),
      );

      final useCase = DeleteStarNyxUseCase(
        starNyxRepository,
        appSettingsRepository,
      );

      await useCase('habit-1', now: DateTime(2026, 4, 13, 8, 30));

      expect(
        (await appSettingsRepository.getAppSettings())?.lastSelectedStarnyxId,
        'habit-2',
      );
    },
  );

  test(
    'toggle completion use case creates then removes a completion',
    () async {
      await starNyxRepository.saveStarnyx(
        StarNyx(
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
      final useCase = ToggleCompletionUseCase(
        starNyxRepository,
        completionRepository,
      );

      final firstResult = await useCase(
        starnyxId: 'habit-1',
        date: DateTime(2026, 4, 10, 12),
        today: DateTime(2026, 4, 10),
      );
      final secondResult = await useCase(
        starnyxId: 'habit-1',
        date: DateTime(2026, 4, 10, 23, 30),
        today: DateTime(2026, 4, 10),
      );

      expect(firstResult, isTrue);
      expect(secondResult, isFalse);
      expect(
        await completionRepository.getCompletionByDate(
          starnyxId: 'habit-1',
          date: DateTime(2026, 4, 10),
        ),
        isNull,
      );
    },
  );

  test('toggle completion use case rejects dates before start date', () async {
    await starNyxRepository.saveStarnyx(
      StarNyx(
        id: 'habit-1',
        title: 'Hydrate',
        description: null,
        color: '#102030',
        startDate: DateTime(2026, 4, 5),
        reminderEnabled: false,
        reminderTime: null,
        createdAt: DateTime(2026, 4, 5, 8),
        updatedAt: DateTime(2026, 4, 5, 8),
      ),
    );
    final useCase = ToggleCompletionUseCase(
      starNyxRepository,
      completionRepository,
    );

    expect(
      () => useCase(
        starnyxId: 'habit-1',
        date: DateTime(2026, 4, 4),
        today: DateTime(2026, 4, 10),
      ),
      throwsA(
        isA<UseCaseValidationException>().having(
          (error) => error.code,
          'code',
          UseCaseValidationCode.dateBeforeStartDate,
        ),
      ),
    );
  });

  test('toggle completion use case rejects future dates', () async {
    await starNyxRepository.saveStarnyx(
      StarNyx(
        id: 'habit-1',
        title: 'Hydrate',
        description: null,
        color: '#102030',
        startDate: DateTime(2026, 4, 1),
        reminderEnabled: false,
        reminderTime: null,
        createdAt: DateTime(2026, 4, 1, 8),
        updatedAt: DateTime(2026, 4, 1, 8),
      ),
    );
    final useCase = ToggleCompletionUseCase(
      starNyxRepository,
      completionRepository,
    );

    expect(
      () => useCase(
        starnyxId: 'habit-1',
        date: DateTime(2026, 4, 11),
        today: DateTime(2026, 4, 10),
      ),
      throwsA(
        isA<UseCaseValidationException>().having(
          (error) => error.code,
          'code',
          UseCaseValidationCode.dateInFuture,
        ),
      ),
    );
  });

  test('toggle completion use case rejects edits older than 7 days', () async {
    await starNyxRepository.saveStarnyx(
      StarNyx(
        id: 'habit-1',
        title: 'Hydrate',
        description: null,
        color: '#102030',
        startDate: DateTime(2026, 4, 1),
        reminderEnabled: false,
        reminderTime: null,
        createdAt: DateTime(2026, 4, 1, 8),
        updatedAt: DateTime(2026, 4, 1, 8),
      ),
    );
    final useCase = ToggleCompletionUseCase(
      starNyxRepository,
      completionRepository,
    );

    expect(
      () => useCase(
        starnyxId: 'habit-1',
        date: DateTime(2026, 4, 2),
        today: DateTime(2026, 4, 10),
      ),
      throwsA(
        isA<UseCaseValidationException>().having(
          (error) => error.code,
          'code',
          UseCaseValidationCode.completionEditWindowExpired,
        ),
      ),
    );
  });

  test(
    'save journal entry use case rejects a second note on the same day',
    () async {
      final useCase = SaveJournalEntryUseCase(journalEntryRepository);

      await useCase(
        starnyxId: 'habit-1',
        date: DateTime(2026, 4, 10, 8),
        content: 'First note',
      );

      expect(
        () => useCase(
          starnyxId: 'habit-1',
          date: DateTime(2026, 4, 10, 20),
          content: 'Second note',
        ),
        throwsA(
          isA<UseCaseValidationException>().having(
            (error) => error.code,
            'code',
            UseCaseValidationCode.journalEntryAlreadyExists,
          ),
        ),
      );
    },
  );

  test('export use case builds the expected backup payload', () async {
    final starnyx = StarNyx(
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
    await starNyxRepository.saveStarnyx(starnyx);
    await completionRepository.saveCompletion(
      Completion(
        starnyxId: 'habit-1',
        date: DateTime(2026, 4, 10),
        completed: true,
      ),
    );
    await journalEntryRepository.saveJournalEntry(
      JournalEntry(
        starnyxId: 'habit-1',
        date: DateTime(2026, 4, 10),
        content: 'Stayed consistent today.',
      ),
    );
    await appSettingsRepository.saveAppSettings(
      AppSettings(
        lastSelectedStarnyxId: 'habit-1',
        updatedAt: DateTime(2026, 4, 10, 8, 30),
      ),
    );

    final useCase = ExportDataUseCase(
      starNyxRepository,
      completionRepository,
      journalEntryRepository,
      appSettingsRepository,
    );
    final payload = await useCase();

    expect(payload['schemaVersion'], 1);
    expect((payload['starnyxs'] as List<dynamic>).length, 1);
    expect((payload['completions'] as List<dynamic>).length, 1);
    expect((payload['journalEntries'] as List<dynamic>).length, 1);
    expect(
      (payload['appSettings'] as Map<String, dynamic>)['lastSelectedStarnyxId'],
      'habit-1',
    );
  });

  test(
    'import use case validates and overwrites current repository data',
    () async {
      await starNyxRepository.saveStarnyx(
        StarNyx(
          id: 'old-id',
          title: 'Old',
          description: null,
          color: '#000000',
          startDate: DateTime(2026, 1, 1),
          reminderEnabled: false,
          reminderTime: null,
          createdAt: DateTime(2026, 1, 1, 8),
          updatedAt: DateTime(2026, 1, 1, 8),
        ),
      );

      final useCase = ImportDataUseCase(
        starNyxRepository,
        completionRepository,
        journalEntryRepository,
        appSettingsRepository,
      );

      await useCase(<String, dynamic>{
        'schemaVersion': 1,
        'starnyxs': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'habit-1',
            'title': 'Hydrate',
            'description': null,
            'color': '#102030',
            'startDate': '2026-04-01',
            'reminderEnabled': false,
            'reminderTime': null,
            'createdAt': '2026-04-01T08:00:00.000',
            'updatedAt': '2026-04-02T09:00:00.000',
          },
        ],
        'completions': <Map<String, dynamic>>[
          <String, dynamic>{
            'starnyxId': 'habit-1',
            'date': '2026-04-10',
            'completed': true,
          },
        ],
        'journalEntries': <Map<String, dynamic>>[
          <String, dynamic>{
            'starnyxId': 'habit-1',
            'date': '2026-04-10',
            'content': 'Stayed consistent today.',
          },
        ],
        'appSettings': <String, dynamic>{
          'lastSelectedStarnyxId': 'habit-1',
          'updatedAt': '2026-04-10T08:30:00.000',
        },
      });

      final allStarnyxs = await starNyxRepository.getAllStarnyxs();

      expect(allStarnyxs.map((item) => item.id), <String>['habit-1']);
      expect(
        await completionRepository.getCompletionByDate(
          starnyxId: 'habit-1',
          date: DateTime(2026, 4, 10),
        ),
        isNotNull,
      );
      expect(
        await journalEntryRepository.getJournalEntryByDate(
          starnyxId: 'habit-1',
          date: DateTime(2026, 4, 10),
        ),
        isNotNull,
      );
      expect(
        (await appSettingsRepository.getAppSettings())?.lastSelectedStarnyxId,
        'habit-1',
      );
    },
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
    items.sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
    return items;
  }

  @override
  Future<StarNyx?> getStarnyxById(String id) async => _items[id];

  @override
  Future<void> saveStarnyx(StarNyx starnyx) async {
    _items[starnyx.id] = starnyx;
  }

  @override
  Stream<List<StarNyx>> watchAllStarnyxs() {
    throw UnimplementedError();
  }
}

class _InMemoryCompletionRepository implements CompletionRepository {
  final Map<String, Completion> _items = <String, Completion>{};

  @override
  Future<void> deleteCompletionByDate({
    required String starnyxId,
    required DateTime date,
  }) async {
    _items.remove(_key(starnyxId, date));
  }

  @override
  Future<void> deleteCompletionsForStarnyx(String starnyxId) async {
    _items.removeWhere((key, value) => value.starnyxId == starnyxId);
  }

  @override
  Future<Completion?> getCompletionByDate({
    required String starnyxId,
    required DateTime date,
  }) async {
    return _items[_key(starnyxId, date)];
  }

  @override
  Future<List<Completion>> getCompletionsForStarnyx(String starnyxId) async {
    final items = _items.values
        .where((item) => item.starnyxId == starnyxId)
        .toList(growable: false);
    items.sort((left, right) => left.date.compareTo(right.date));
    return items;
  }

  @override
  Future<void> saveCompletion(Completion completion) async {
    _items[_key(completion.starnyxId, completion.date)] = completion;
  }

  @override
  Stream<List<Completion>> watchCompletionsForStarnyx(String starnyxId) {
    throw UnimplementedError();
  }
}

class _InMemoryJournalEntryRepository implements JournalEntryRepository {
  final Map<String, JournalEntry> _items = <String, JournalEntry>{};

  @override
  Future<void> deleteJournalEntriesForStarnyx(String starnyxId) async {
    _items.removeWhere((key, value) => value.starnyxId == starnyxId);
  }

  @override
  Future<void> deleteJournalEntryByDate({
    required String starnyxId,
    required DateTime date,
  }) async {
    _items.remove(_key(starnyxId, date));
  }

  @override
  Future<JournalEntry?> getJournalEntryByDate({
    required String starnyxId,
    required DateTime date,
  }) async {
    return _items[_key(starnyxId, date)];
  }

  @override
  Future<List<JournalEntry>> getJournalEntriesForStarnyx(
    String starnyxId,
  ) async {
    final items = _items.values
        .where((item) => item.starnyxId == starnyxId)
        .toList(growable: false);
    items.sort((left, right) => right.date.compareTo(left.date));
    return items;
  }

  @override
  Future<void> saveJournalEntry(JournalEntry entry) async {
    _items[_key(entry.starnyxId, entry.date)] = entry;
  }

  @override
  Stream<List<JournalEntry>> watchJournalEntriesForStarnyx(String starnyxId) {
    throw UnimplementedError();
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
  Stream<AppSettings?> watchAppSettings() {
    throw UnimplementedError();
  }
}

String _key(String starnyxId, DateTime date) {
  return '$starnyxId:${date.toIso8601String()}';
}

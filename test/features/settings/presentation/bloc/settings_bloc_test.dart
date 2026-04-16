import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/core/services/core_services.dart';
import 'package:starnyx/domain/entities/domain_entities.dart';
import 'package:starnyx/domain/repositories/domain_repositories.dart';
import 'package:starnyx/domain/usecases/domain_usecases.dart';
import 'package:starnyx/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:starnyx/features/settings/presentation/bloc/settings_event.dart';

void main() {
  late _InMemoryStarNyxRepository starNyxRepository;
  late _InMemoryCompletionRepository completionRepository;
  late _InMemoryJournalEntryRepository journalEntryRepository;
  late _InMemoryAppSettingsRepository appSettingsRepository;
  late _FakeNotificationService notificationService;
  late SettingsBloc bloc;

  setUp(() {
    starNyxRepository = _InMemoryStarNyxRepository();
    completionRepository = _InMemoryCompletionRepository();
    journalEntryRepository = _InMemoryJournalEntryRepository();
    appSettingsRepository = _InMemoryAppSettingsRepository();
    notificationService = _FakeNotificationService();

    final exportUseCase = ExportDataUseCase(
      starNyxRepository,
      completionRepository,
      journalEntryRepository,
      appSettingsRepository,
    );
    final importUseCase = ImportDataUseCase(
      starNyxRepository,
      completionRepository,
      journalEntryRepository,
      appSettingsRepository,
    );
    final syncUseCase = SyncNotificationsUseCase(
      notificationService,
      starNyxRepository,
    );

    bloc = SettingsBloc(
      exportDataUseCase: exportUseCase,
      importDataUseCase: importUseCase,
      syncNotificationsUseCase: syncUseCase,
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  test('import success rebuilds reminders from imported local data', () async {
    bloc.add(
      SettingsImportRequested(<String, dynamic>{
        'schemaVersion': 1,
        'starnyxs': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'habit-1',
            'title': 'Hydrate',
            'description': null,
            'color': '#102030',
            'startDate': '2026-04-01',
            'reminderEnabled': true,
            'reminderTime': '09:30',
            'createdAt': '2026-04-01T08:00:00.000',
            'updatedAt': '2026-04-02T09:00:00.000',
          },
        ],
        'completions': <Map<String, dynamic>>[],
        'journalEntries': <Map<String, dynamic>>[],
        'appSettings': <String, dynamic>{
          'lastSelectedStarnyxId': 'habit-1',
          'updatedAt': '2026-04-10T08:30:00.000',
        },
      }),
    );

    await pumpEventQueue(times: 10);

    expect(bloc.state.importStatus, AsyncStatus.success);
    expect(notificationService.cancelAllCount, 1);
    expect(notificationService.createdReminderIds, <String>['habit-1']);
  });

  test('import failure does not rebuild reminders', () async {
    bloc.add(
      SettingsImportRequested(<String, dynamic>{
        'schemaVersion': 2,
        'starnyxs': <Map<String, dynamic>>[],
        'completions': <Map<String, dynamic>>[],
        'journalEntries': <Map<String, dynamic>>[],
        'appSettings': <String, dynamic>{
          'lastSelectedStarnyxId': null,
          'updatedAt': '2026-04-10T08:30:00.000',
        },
      }),
    );

    await pumpEventQueue(times: 10);

    expect(bloc.state.importStatus, AsyncStatus.failure);
    expect(notificationService.cancelAllCount, 0);
    expect(notificationService.createdReminderIds, isEmpty);
  });
}

class _FakeNotificationService implements NotificationService {
  int cancelAllCount = 0;
  final List<String> createdReminderIds = <String>[];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> createReminder(StarNyx starnyx) async {
    createdReminderIds.add(starnyx.id);
  }

  @override
  Future<void> updateReminder(StarNyx starnyx) async {}

  @override
  Future<void> cancelReminder(String starnyxId) async {}

  @override
  Future<void> cancelAllReminders() async {
    cancelAllCount += 1;
  }
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
  Stream<List<StarNyx>> watchAllStarnyxs() async* {
    yield await getAllStarnyxs();
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
    _items.removeWhere((_, value) => value.starnyxId == starnyxId);
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
    return _items.values
        .where((item) => item.starnyxId == starnyxId)
        .toList(growable: false);
  }

  @override
  Future<void> saveCompletion(Completion completion) async {
    _items[_key(completion.starnyxId, completion.date)] = completion;
  }

  @override
  Stream<List<Completion>> watchCompletionsForStarnyx(String starnyxId) async* {
    yield await getCompletionsForStarnyx(starnyxId);
  }
}

class _InMemoryJournalEntryRepository implements JournalEntryRepository {
  final List<JournalEntry> _entries = <JournalEntry>[];

  @override
  Future<void> deleteJournalEntriesForStarnyx(String starnyxId) async {
    _entries.removeWhere((item) => item.starnyxId == starnyxId);
  }

  @override
  Future<void> deleteJournalEntryById(int id) async {
    _entries.removeWhere((item) => item.id == id);
  }

  @override
  Future<List<JournalEntry>> getJournalEntriesForDate({
    required String starnyxId,
    required DateTime date,
  }) async {
    return _entries
        .where((item) => item.starnyxId == starnyxId && item.date == date)
        .toList(growable: false);
  }

  @override
  Future<List<JournalEntry>> getJournalEntriesForStarnyx(
    String starnyxId,
  ) async {
    return _entries
        .where((item) => item.starnyxId == starnyxId)
        .toList(growable: false);
  }

  @override
  Future<void> saveJournalEntry(JournalEntry entry) async {
    _entries.add(entry);
  }

  @override
  Stream<List<JournalEntry>> watchJournalEntriesForStarnyx(
    String starnyxId,
  ) async* {
    yield await getJournalEntriesForStarnyx(starnyxId);
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

String _key(String starnyxId, DateTime date) {
  return '$starnyxId:${date.toIso8601String()}';
}

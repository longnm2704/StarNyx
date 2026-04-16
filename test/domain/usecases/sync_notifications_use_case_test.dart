import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/core/services/core_services.dart';
import 'package:starnyx/domain/entities/domain_entities.dart';
import 'package:starnyx/domain/repositories/domain_repositories.dart';
import 'package:starnyx/domain/usecases/domain_usecases.dart';

void main() {
  late _FakeNotificationService notificationService;
  late _InMemoryStarNyxRepository starnyxRepository;
  late SyncNotificationsUseCase useCase;

  setUp(() {
    notificationService = _FakeNotificationService();
    starnyxRepository = _InMemoryStarNyxRepository();
    useCase = SyncNotificationsUseCase(notificationService, starnyxRepository);
  });

  test('onStarnyxSaved updates reminder when reminder is enabled', () async {
    final starnyx = _sampleStarnyx(
      reminderEnabled: true,
      reminderTime: '09:30',
    );

    await useCase.onStarnyxSaved(starnyx);

    expect(notificationService.updatedReminders, <String>[starnyx.id]);
    expect(notificationService.cancelledReminderIds, isEmpty);
  });

  test('onStarnyxSaved cancels reminder when reminder is disabled', () async {
    final starnyx = _sampleStarnyx(reminderEnabled: false, reminderTime: null);

    await useCase.onStarnyxSaved(starnyx);

    expect(notificationService.updatedReminders, isEmpty);
    expect(notificationService.cancelledReminderIds, <String>[starnyx.id]);
  });

  test('onStarnyxDeleted cancels reminder for that id', () async {
    await useCase.onStarnyxDeleted('habit-1');

    expect(notificationService.cancelledReminderIds, <String>['habit-1']);
  });

  test(
    'rebuildAllFromLocalData cancels all then schedules enabled reminders',
    () async {
      await starnyxRepository.saveStarnyx(
        _sampleStarnyx(id: 'a', reminderEnabled: true, reminderTime: '08:00'),
      );
      await starnyxRepository.saveStarnyx(
        _sampleStarnyx(id: 'b', reminderEnabled: false, reminderTime: null),
      );
      await starnyxRepository.saveStarnyx(
        _sampleStarnyx(id: 'c', reminderEnabled: true, reminderTime: '21:00'),
      );

      await useCase.rebuildAllFromLocalData();

      expect(notificationService.cancelAllCount, 1);
      expect(notificationService.createdReminders, <String>['a', 'c']);
    },
  );
}

StarNyx _sampleStarnyx({
  String id = 'habit-1',
  required bool reminderEnabled,
  required String? reminderTime,
}) {
  return StarNyx(
    id: id,
    title: 'Hydrate',
    description: null,
    color: '#102030',
    startDate: DateTime(2026, 4, 10),
    reminderEnabled: reminderEnabled,
    reminderTime: reminderTime,
    createdAt: DateTime(2026, 4, 10, 8),
    updatedAt: DateTime(2026, 4, 10, 8),
  );
}

class _FakeNotificationService implements NotificationService {
  final List<String> createdReminders = <String>[];
  final List<String> updatedReminders = <String>[];
  final List<String> cancelledReminderIds = <String>[];
  int cancelAllCount = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> createReminder(StarNyx starnyx) async {
    createdReminders.add(starnyx.id);
  }

  @override
  Future<void> updateReminder(StarNyx starnyx) async {
    updatedReminders.add(starnyx.id);
  }

  @override
  Future<void> cancelReminder(String starnyxId) async {
    cancelledReminderIds.add(starnyxId);
  }

  @override
  Future<void> cancelAllReminders() async {
    cancelAllCount += 1;
  }
}

class _InMemoryStarNyxRepository implements StarNyxRepository {
  final Map<String, StarNyx> _items = <String, StarNyx>{};

  @override
  Future<void> saveStarnyx(StarNyx starnyx) async {
    _items[starnyx.id] = starnyx;
  }

  @override
  Future<void> deleteStarnyxById(String id) async {
    _items.remove(id);
  }

  @override
  Future<List<StarNyx>> getAllStarnyxs() async {
    final items = _items.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return items;
  }

  @override
  Future<StarNyx?> getStarnyxById(String id) async {
    return _items[id];
  }

  @override
  Stream<List<StarNyx>> watchAllStarnyxs() async* {
    yield _items.values.toList();
  }
}

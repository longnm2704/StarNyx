import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/core/services/local_notification_service.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  late _FakeNotificationClient client;
  late LocalNotificationService service;

  setUp(() {
    client = _FakeNotificationClient();
    service = LocalNotificationService(
      client: client,
      now: () => DateTime(2026, 4, 16, 8, 0),
    );
  });

  test('initialize is idempotent', () async {
    await service.initialize();
    await service.initialize();

    expect(client.initializeCount, 1);
    expect(client.createChannelCount, 1);
  });

  test('create reminder schedules once when reminder is enabled', () async {
    await service.initialize();

    await service.createReminder(
      _sampleStarNyx(reminderEnabled: true, reminderTime: '09:30'),
    );

    expect(client.scheduled.length, 1);
    final request = client.scheduled.single;
    expect(request.title, 'Hydrate');
    expect(request.body, 'Time to check in on your StarNyx.');
    expect(request.matchDateTimeComponents, DateTimeComponents.time);
    expect(request.scheduledDate.hour, 9);
    expect(request.scheduledDate.minute, 30);
    expect(
      request.scheduledDate.isAfter(
        tz.TZDateTime.from(DateTime(2026, 4, 16, 8), tz.local),
      ),
      isTrue,
    );
  });

  test('create reminder is ignored when reminder is disabled', () async {
    await service.initialize();

    await service.createReminder(
      _sampleStarNyx(reminderEnabled: false, reminderTime: '09:30'),
    );

    expect(client.scheduled, isEmpty);
  });

  test('update reminder cancels old id before scheduling a new one', () async {
    await service.initialize();

    await service.updateReminder(
      _sampleStarNyx(reminderEnabled: true, reminderTime: '20:00'),
    );

    expect(client.cancelled.length, 1);
    expect(client.scheduled.length, 1);
    expect(client.cancelled.single, client.scheduled.single.id);
  });

  test('cancel reminder cancels by deterministic id', () async {
    await service.initialize();

    await service.cancelReminder('habit-1');

    expect(client.cancelled.length, 1);
    await service.cancelReminder('habit-1');
    expect(client.cancelled[0], client.cancelled[1]);
  });

  test('cancel all reminders delegates to the client', () async {
    await service.initialize();
    await service.cancelAllReminders();

    expect(client.cancelAllCount, 1);
  });
}

StarNyx _sampleStarNyx({
  required bool reminderEnabled,
  required String? reminderTime,
}) {
  return StarNyx(
    id: 'habit-1',
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

class _FakeNotificationClient implements NotificationClient {
  int initializeCount = 0;
  int createChannelCount = 0;
  final List<_ScheduledRequest> scheduled = <_ScheduledRequest>[];
  final List<int> cancelled = <int>[];
  int cancelAllCount = 0;

  @override
  Future<void> initialize(InitializationSettings settings) async {
    initializeCount += 1;
  }

  @override
  Future<void> createAndroidChannel(AndroidNotificationChannel channel) async {
    createChannelCount += 1;
  }

  @override
  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails details,
    required AndroidScheduleMode androidScheduleMode,
    required DateTimeComponents matchDateTimeComponents,
  }) async {
    scheduled.add(
      _ScheduledRequest(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        matchDateTimeComponents: matchDateTimeComponents,
      ),
    );
  }

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCount += 1;
  }
}

class _ScheduledRequest {
  const _ScheduledRequest({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDate,
    required this.matchDateTimeComponents,
  });

  final int id;
  final String title;
  final String body;
  final tz.TZDateTime scheduledDate;
  final DateTimeComponents matchDateTimeComponents;
}

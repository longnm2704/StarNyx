import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:starnyx/core/utils/reminder_time_utils.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'notification_service.dart';

const String _channelId = 'starnyx.daily.reminder';
const String _channelName = 'StarNyx Daily Reminder';
const String _channelDescription = 'Daily reminders for active StarNyx habits.';

int _notificationIdFor(String starnyxId) {
  const int fnvPrime = 0x01000193;
  var hash = 0x811C9DC5;

  for (final codeUnit in starnyxId.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * fnvPrime) & 0x7fffffff;
  }

  return hash;
}

/// Local implementation backed by flutter_local_notifications.
class LocalNotificationService implements NotificationService {
  LocalNotificationService({
    NotificationClient? client,
    DateTime Function()? now,
  }) : _client = client ?? FlutterLocalNotificationClient(),
       _now = now ?? DateTime.now;

  final NotificationClient _client;
  final DateTime Function() _now;

  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    tz_data.initializeTimeZones();

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _client.initialize(settings);
    await _client.createAndroidChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      ),
    );

    _initialized = true;
  }

  @override
  Future<void> createReminder(StarNyx starnyx) async {
    final reminderTime = starnyx.reminderTime;
    if (!starnyx.reminderEnabled || reminderTime == null) {
      return;
    }

    final parsed = ReminderTimeUtils.parseTimeString(
      reminderTime,
      anchorDate: _now(),
    );
    if (parsed == null) {
      return;
    }

    final scheduledAt = _nextDailySchedule(parsed);
    final notificationId = _notificationIdFor(starnyx.id);
    final details = const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _client.zonedSchedule(
      id: notificationId,
      title: starnyx.title,
      body: 'Time to check in on your StarNyx.',
      scheduledDate: scheduledAt,
      details: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> updateReminder(StarNyx starnyx) async {
    await cancelReminder(starnyx.id);
    await createReminder(starnyx);
  }

  @override
  Future<void> cancelReminder(String starnyxId) {
    return _client.cancel(_notificationIdFor(starnyxId));
  }

  tz.TZDateTime _nextDailySchedule(DateTime reminderDateTime) {
    final now = tz.TZDateTime.from(_now(), tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      reminderDateTime.hour,
      reminderDateTime.minute,
    );

    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

/// Thin adapter to keep the service testable without plugin channels.
abstract class NotificationClient {
  Future<void> initialize(InitializationSettings settings);

  Future<void> createAndroidChannel(AndroidNotificationChannel channel);

  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails details,
    required AndroidScheduleMode androidScheduleMode,
    required DateTimeComponents matchDateTimeComponents,
  });

  Future<void> cancel(int id);
}

class FlutterLocalNotificationClient implements NotificationClient {
  FlutterLocalNotificationClient({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<void> initialize(InitializationSettings settings) {
    return _plugin.initialize(settings: settings);
  }

  @override
  Future<void> createAndroidChannel(AndroidNotificationChannel channel) async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(channel);
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
  }) {
    return _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: androidScheduleMode,
      matchDateTimeComponents: matchDateTimeComponents,
    );
  }

  @override
  Future<void> cancel(int id) {
    return _plugin.cancel(id: id);
  }
}

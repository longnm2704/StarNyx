import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:starnyx/core/services/app_log_service.dart';
import 'package:starnyx/core/utils/reminder_time_utils.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
    LocalTimezoneProvider? timezoneProvider,
    AppLogService logger = const NoOpAppLogService(),
    DateTime Function()? now,
  }) : _client = client ?? FlutterLocalNotificationClient(),
       _timezoneProvider = timezoneProvider ?? FlutterLocalTimezoneProvider(),
       _logger = logger,
       _now = now ?? DateTime.now;

  final NotificationClient _client;
  final LocalTimezoneProvider _timezoneProvider;
  final AppLogService _logger;
  final DateTime Function() _now;

  bool _initialized = false;
  bool _timeZonesInitialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      _logger.debug('LocalNotificationService', 'initialize skipped');
      return;
    }

    _logger.debug('LocalNotificationService', 'initialize begin');
    await _configureLocalTimeZone();

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
    _logger.debug('LocalNotificationService', 'initialize success');
  }

  @override
  Future<void> createReminder(StarNyx starnyx) async {
    final reminderTime = starnyx.reminderTime;
    if (!starnyx.reminderEnabled || reminderTime == null) {
      _logger.debug(
        'LocalNotificationService',
        'create skipped id=${starnyx.id} reminderEnabled=${starnyx.reminderEnabled}',
      );
      return;
    }

    _logger.debug(
      'LocalNotificationService',
      'create begin id=${starnyx.id} reminderTime=$reminderTime',
    );
    await _configureLocalTimeZone();

    final parsed = ReminderTimeUtils.parseTimeString(
      reminderTime,
      anchorDate: _now(),
    );
    if (parsed == null) {
      _logger.debug(
        'LocalNotificationService',
        'create skipped invalid reminderTime id=${starnyx.id} reminderTime=$reminderTime',
      );
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
    _logger.debug(
      'LocalNotificationService',
      'create success id=${starnyx.id} notificationId=$notificationId '
          'scheduledAt=$scheduledAt location=${scheduledAt.location.name}',
    );
  }

  @override
  Future<void> updateReminder(StarNyx starnyx) async {
    _logger.debug('LocalNotificationService', 'update begin id=${starnyx.id}');
    await cancelReminder(starnyx.id);
    await createReminder(starnyx);
    _logger.debug(
      'LocalNotificationService',
      'update success id=${starnyx.id}',
    );
  }

  @override
  Future<void> cancelReminder(String starnyxId) async {
    final notificationId = _notificationIdFor(starnyxId);
    _logger.debug(
      'LocalNotificationService',
      'cancel begin id=$starnyxId notificationId=$notificationId',
    );
    await _client.cancel(notificationId);
    _logger.debug('LocalNotificationService', 'cancel success id=$starnyxId');
  }

  @override
  Future<void> cancelAllReminders() async {
    _logger.debug('LocalNotificationService', 'cancel all begin');
    await _client.cancelAll();
    _logger.debug('LocalNotificationService', 'cancel all success');
  }

  Future<void> _configureLocalTimeZone() async {
    if (!_timeZonesInitialized) {
      tz_data.initializeTimeZones();
      _timeZonesInitialized = true;
      _logger.debug(
        'LocalNotificationService',
        'timezone database initialized',
      );
    }

    final timezoneName = await _timezoneProvider.getLocalTimezone();
    if (timezoneName == null || timezoneName.isEmpty) {
      _logger.debug('LocalNotificationService', 'timezone unavailable');
      return;
    }

    try {
      tz.setLocalLocation(tz.getLocation(timezoneName));
      _logger.debug(
        'LocalNotificationService',
        'timezone configured name=$timezoneName',
      );
    } on Object {
      // Keep timezone's default location if the platform returns an unknown id.
      _logger.debug(
        'LocalNotificationService',
        'timezone ignored unknown name=$timezoneName',
      );
    }
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

/// Resolves the device timezone name, e.g. `Asia/Ho_Chi_Minh`.
abstract class LocalTimezoneProvider {
  Future<String?> getLocalTimezone();
}

class FlutterLocalTimezoneProvider implements LocalTimezoneProvider {
  @override
  Future<String?> getLocalTimezone() async {
    try {
      return FlutterTimezone.getLocalTimezone();
    } on Object {
      return null;
    }
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

  Future<void> cancelAll();
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

  @override
  Future<void> cancelAll() {
    return _plugin.cancelAll();
  }
}

import 'package:starnyx/domain/entities/starnyx.dart';

/// Contract for habit reminder notifications.
abstract class NotificationService {
  /// Prepares platform notification resources. Does not ask for permission:
  /// that happens when the user first turns a reminder on.
  Future<void> initialize();

  /// Asks the OS for notification permission (the system prompt only shows
  /// while undecided) and returns whether reminders can be shown. Not cached:
  /// the user can change it in system settings at any time.
  Future<bool> requestPermission();

  /// Whether notifications are currently allowed, without prompting.
  Future<bool> hasPermission();

  /// Creates a reminder notification schedule for one StarNyx.
  Future<void> createReminder(StarNyx starnyx);

  /// Updates an existing reminder by replacing any existing schedule.
  Future<void> updateReminder(StarNyx starnyx);

  /// Cancels a reminder schedule for one StarNyx.
  Future<void> cancelReminder(String starnyxId);

  /// Cancels all reminder schedules managed by this app.
  Future<void> cancelAllReminders();

  /// Replaces the translator used for notification body text. Set once at
  /// app start with a context-free translator that reads the current locale;
  /// after a locale change, re-sync reminders.
  void setTranslator(
    String Function(String key, {Map<String, dynamic>? namedArgs}) tr,
  );
}

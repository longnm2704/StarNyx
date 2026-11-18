import 'package:starnyx/domain/entities/starnyx.dart';

/// Contract for habit reminder notifications.
abstract class NotificationService {
  /// Prepares platform notification resources.
  Future<void> initialize();

  /// Creates a reminder notification schedule for one StarNyx.
  Future<void> createReminder(StarNyx starnyx);

  /// Updates an existing reminder by replacing any existing schedule.
  Future<void> updateReminder(StarNyx starnyx);

  /// Cancels a reminder schedule for one StarNyx.
  Future<void> cancelReminder(String starnyxId);

  /// Cancels all reminder schedules managed by this app.
  Future<void> cancelAllReminders();

  /// Replaces the translator used for notification body text. Call this when
  /// the app locale changes, then re-sync reminders.
  void setTranslator(
    String Function(String key, {Map<String, dynamic>? namedArgs}) tr,
  );
}

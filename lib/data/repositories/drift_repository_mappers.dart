import 'package:starnyx/core/utils/date_utils.dart';
import 'package:starnyx/data/db/app_database.dart' as db;
import 'package:starnyx/domain/entities/domain_entities.dart' as domain;

// Shared date formatter for date-only keys stored in SQLite and JSON.
String dateKeyFromDateTime(DateTime value) {
  final normalized = DateUtils.dateOnly(value);
  final year = normalized.year.toString().padLeft(4, '0');
  final month = normalized.month.toString().padLeft(2, '0');
  final day = normalized.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

// Shared parser for date-only keys stored as YYYY-MM-DD.
DateTime dateTimeFromDateKey(String value) {
  return DateUtils.dateOnly(DateTime.parse(value));
}

// Maps Drift StarNyx rows into domain objects.
extension DriftStarNyxMapper on db.StarNyx {
  domain.StarNyx toDomain() {
    return domain.StarNyx(
      id: id,
      title: title,
      description: description,
      color: color,
      startDate: dateTimeFromDateKey(startDate),
      reminderEnabled: reminderEnabled,
      reminderTime: reminderTime,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

// Maps Drift Completion rows into domain objects.
extension DriftCompletionMapper on db.Completion {
  domain.Completion toDomain() {
    return domain.Completion(
      starnyxId: starnyxId,
      date: dateTimeFromDateKey(date),
      completed: completed,
    );
  }
}

// Maps Drift JournalEntry rows into domain objects.
extension DriftJournalEntryMapper on db.JournalEntry {
  domain.JournalEntry toDomain() {
    return domain.JournalEntry(
      starnyxId: starnyxId,
      date: dateTimeFromDateKey(date),
      content: content,
    );
  }
}

// Maps Drift AppSetting rows into domain objects.
extension DriftAppSettingMapper on db.AppSetting {
  domain.AppSettings toDomain() {
    return domain.AppSettings(
      lastSelectedStarnyxId: lastSelectedStarnyxId,
      updatedAt: updatedAt,
    );
  }
}

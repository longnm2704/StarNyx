import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starnyx/core/services/core_services.dart';
import 'package:starnyx/data/db/app_database.dart';
import 'package:starnyx/data/repositories/data_repositories.dart';
import 'package:starnyx/domain/entities/domain_entities.dart' as domain;
import 'package:starnyx/domain/usecases/domain_usecases.dart';

void main() {
  test(
    'seeded data is wiped, settings reset, reminders and color cleared',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final starnyxs = DriftStarNyxRepository(database);
      final completions = DriftCompletionRepository(database);
      final journals = DriftJournalEntryRepository(database);
      final settings = DriftAppSettingsRepository(database);

      final habit = domain.StarNyx(
        id: 'habit-1',
        title: 'Hydrate',
        description: null,
        color: '#102030',
        startDate: DateTime(2026, 4, 1),
        reminderEnabled: true,
        reminderTime: '09:30',
        createdAt: DateTime(2026, 4, 1),
        updatedAt: DateTime(2026, 4, 1),
      );
      await starnyxs.saveStarnyx(habit);
      await completions.saveCompletion(
        domain.Completion(
          starnyxId: habit.id,
          date: DateTime(2026, 4, 2),
          completed: true,
        ),
      );
      await journals.saveJournalEntry(
        domain.JournalEntry(
          id: 0,
          starnyxId: habit.id,
          date: DateTime(2026, 4, 2),
          content: 'Felt good',
          createdAt: DateTime(2026, 4, 2, 21),
        ),
      );
      await settings.saveAppSettings(
        domain.AppSettings(
          lastSelectedStarnyxId: habit.id,
          updatedAt: DateTime(2026, 4, 2),
        ),
      );

      SharedPreferences.setMockInitialValues(<String, Object>{});
      final colorCache = ActiveStarnyxColorCache(
        await SharedPreferences.getInstance(),
      );
      await colorCache.saveColor(const Color(0xFF102030));
      final notifications = _FakeNotificationService();
      final resetAt = DateTime(2026, 5, 1);

      await DeleteAllDataUseCase(
        () => database.clearAll(now: resetAt),
        SyncNotificationsUseCase(notifications, starnyxs),
        colorCache,
      ).call();

      expect(await database.select(database.starNyxs).get(), isEmpty);
      expect(await database.select(database.completions).get(), isEmpty);
      expect(await database.select(database.journalEntries).get(), isEmpty);
      final settingsRows = await database.select(database.appSettings).get();
      expect(settingsRows, hasLength(1));
      expect(settingsRows.single.lastSelectedStarnyxId, isNull);
      expect(settingsRows.single.updatedAt, resetAt);
      expect(notifications.cancelAllCount, 1);
      expect(colorCache.readColor(), isNull);
    },
  );
}

class _FakeNotificationService implements NotificationService {
  int cancelAllCount = 0;

  @override
  Future<void> cancelAllReminders() async => cancelAllCount += 1;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

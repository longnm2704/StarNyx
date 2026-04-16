import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/domain/entities/domain_entities.dart';
import 'package:starnyx/domain/repositories/domain_repositories.dart';

// Keeps repository contracts importable and fakeable for later use-case tests.
void main() {
  test('domain repository contracts can be implemented by fakes', () async {
    final starnyxRepository = _FakeStarNyxRepository();
    final completionRepository = _FakeCompletionRepository();
    final journalRepository = _FakeJournalEntryRepository();
    final appSettingsRepository = _FakeAppSettingsRepository();

    expect(await starnyxRepository.getAllStarnyxs(), isEmpty);
    expect(
      await completionRepository.getCompletionsForStarnyx('habit-1'),
      isEmpty,
    );
    expect(
      await journalRepository.getJournalEntriesForStarnyx('habit-1'),
      isEmpty,
    );
    expect(await appSettingsRepository.getAppSettings(), isNull);
  });
}

class _FakeStarNyxRepository implements StarNyxRepository {
  @override
  Future<void> deleteStarnyxById(String id) async {}

  @override
  Future<List<StarNyx>> getAllStarnyxs() async => const <StarNyx>[];

  @override
  Future<StarNyx?> getStarnyxById(String id) async => null;

  @override
  Future<void> saveStarnyx(StarNyx starnyx) async {}

  @override
  Stream<List<StarNyx>> watchAllStarnyxs() =>
      const Stream<List<StarNyx>>.empty();
}

class _FakeCompletionRepository implements CompletionRepository {
  @override
  Future<void> deleteCompletionByDate({
    required String starnyxId,
    required DateTime date,
  }) async {}

  @override
  Future<void> deleteCompletionsForStarnyx(String starnyxId) async {}

  @override
  Future<Completion?> getCompletionByDate({
    required String starnyxId,
    required DateTime date,
  }) async => null;

  @override
  Future<List<Completion>> getCompletionsForStarnyx(String starnyxId) async =>
      const <Completion>[];

  @override
  Future<void> saveCompletion(Completion completion) async {}

  @override
  Stream<List<Completion>> watchCompletionsForStarnyx(String starnyxId) =>
      const Stream<List<Completion>>.empty();
}

class _FakeJournalEntryRepository implements JournalEntryRepository {
  @override
  Future<void> deleteJournalEntriesForStarnyx(String starnyxId) async {}

  @override
  Future<void> deleteJournalEntryById(int id) async {}

  @override
  Future<List<JournalEntry>> getJournalEntriesForDate({
    required String starnyxId,
    required DateTime date,
  }) async => const <JournalEntry>[];

  @override
  Future<List<JournalEntry>> getJournalEntriesForStarnyx(
    String starnyxId,
  ) async => const <JournalEntry>[];

  @override
  Future<void> saveJournalEntry(JournalEntry entry) async {}

  @override
  Stream<List<JournalEntry>> watchJournalEntriesForStarnyx(String starnyxId) =>
      const Stream<List<JournalEntry>>.empty();
}

class _FakeAppSettingsRepository implements AppSettingsRepository {
  @override
  Future<AppSettings?> getAppSettings() async => null;

  @override
  Future<void> saveAppSettings(AppSettings settings) async {}

  @override
  Stream<AppSettings?> watchAppSettings() => const Stream<AppSettings?>.empty();
}

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:starnyx/core/constants/enums.dart';
import 'package:starnyx/domain/entities/journal_entry.dart';
import 'package:starnyx/domain/usecases/save_journal_entry_use_case.dart';
import 'package:starnyx/domain/repositories/journal_entry_repository.dart';
import 'package:starnyx/domain/usecases/delete_journal_entry_use_case.dart';
import 'package:starnyx/features/journal/presentation/bloc/journal_bloc.dart';
import 'package:starnyx/features/journal/presentation/bloc/journal_event.dart';
import 'package:starnyx/domain/usecases/watch_journal_entries_for_starnyx_use_case.dart';

void main() {
  late _InMemoryJournalEntryRepository repository;
  late JournalBloc bloc;

  setUp(() {
    repository = _InMemoryJournalEntryRepository();
    bloc = JournalBloc(
      saveJournalEntryUseCase: SaveJournalEntryUseCase(repository),
      watchJournalEntriesForStarnyxUseCase:
          WatchJournalEntriesForStarnyxUseCase(repository),
      deleteJournalEntryUseCase: DeleteJournalEntryUseCase(repository),
      nowBuilder: () => DateTime(2026, 4, 16, 8, 0),
    );
  });

  tearDown(() async {
    await bloc.close();
    await repository.dispose();
  });

  test('start subscribes and loads journal entries newest-first', () async {
    await repository.saveJournalEntry(
      JournalEntry(
        starnyxId: 's-1',
        date: DateTime(2026, 4, 15),
        content: 'Older note',
      ),
    );
    await repository.saveJournalEntry(
      JournalEntry(
        starnyxId: 's-1',
        date: DateTime(2026, 4, 16),
        content: 'Today note',
      ),
    );

    bloc.add(const JournalStarted('s-1'));
    await pumpEventQueue(times: 5);

    expect(bloc.state.starnyxId, 's-1');
    expect(bloc.state.status, JournalStatus.success);
    expect(bloc.state.entries, hasLength(2));
    expect(bloc.state.entries.first.content, 'Today note');
  });

  test('draft changed updates state content', () async {
    bloc.add(const JournalStarted('s-1'));
    await pumpEventQueue(times: 3);

    bloc.add(const JournalDraftChanged('A quick reflection.'));
    await pumpEventQueue();

    expect(bloc.state.draftContent, 'A quick reflection.');
  });

  test('save creates today journal entry and clears draft', () async {
    bloc.add(const JournalStarted('s-1'));
    await pumpEventQueue(times: 3);
    bloc.add(const JournalDraftChanged('Today I completed my habit.'));
    await pumpEventQueue();

    bloc.add(const JournalSaveRequested());
    await pumpEventQueue(times: 6);

    expect(bloc.state.saveStatus, AsyncStatus.success);
    expect(bloc.state.draftContent, isEmpty);
    final saved = await repository.getJournalEntryByDate(
      starnyxId: 's-1',
      date: DateTime(2026, 4, 16),
    );
    expect(saved?.content, 'Today I completed my habit.');
  });

  test('save fails when today entry already exists', () async {
    await repository.saveJournalEntry(
      JournalEntry(
        starnyxId: 's-1',
        date: DateTime(2026, 4, 16),
        content: 'Existing note',
      ),
    );
    bloc.add(const JournalStarted('s-1'));
    await pumpEventQueue(times: 3);
    bloc.add(const JournalDraftChanged('Trying to create another one.'));
    await pumpEventQueue();

    bloc.add(const JournalSaveRequested());
    await pumpEventQueue(times: 3);

    expect(bloc.state.saveStatus, AsyncStatus.failure);
    expect(
      bloc.state.errorMessage,
      'Only one journal entry is allowed per day.',
    );
  });

  test('delete removes entry for selected date', () async {
    await repository.saveJournalEntry(
      JournalEntry(
        starnyxId: 's-1',
        date: DateTime(2026, 4, 16),
        content: 'Delete me',
      ),
    );
    bloc.add(const JournalStarted('s-1'));
    await pumpEventQueue(times: 3);

    bloc.add(JournalDeleteRequested(DateTime(2026, 4, 16)));
    await pumpEventQueue(times: 5);

    expect(bloc.state.deleteStatus, AsyncStatus.success);
    final deleted = await repository.getJournalEntryByDate(
      starnyxId: 's-1',
      date: DateTime(2026, 4, 16),
    );
    expect(deleted, isNull);
  });
}

class _InMemoryJournalEntryRepository implements JournalEntryRepository {
  final Map<String, Map<DateTime, JournalEntry>> _entriesByStarnyx =
      <String, Map<DateTime, JournalEntry>>{};
  final Map<String, StreamController<List<JournalEntry>>> _controllers =
      <String, StreamController<List<JournalEntry>>>{};

  Future<void> dispose() async {
    for (final controller in _controllers.values) {
      await controller.close();
    }
  }

  @override
  Future<List<JournalEntry>> getJournalEntriesForStarnyx(
    String starnyxId,
  ) async {
    return _sortedEntries(starnyxId);
  }

  @override
  Stream<List<JournalEntry>> watchJournalEntriesForStarnyx(String starnyxId) {
    final controller = _controllers.putIfAbsent(
      starnyxId,
      () => StreamController<List<JournalEntry>>.broadcast(),
    );
    scheduleMicrotask(() {
      if (!controller.isClosed) {
        controller.add(_sortedEntries(starnyxId));
      }
    });
    return controller.stream;
  }

  @override
  Future<JournalEntry?> getJournalEntryByDate({
    required String starnyxId,
    required DateTime date,
  }) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return _entriesByStarnyx[starnyxId]?[normalizedDate];
  }

  @override
  Future<void> saveJournalEntry(JournalEntry entry) async {
    final normalizedDate = DateTime(
      entry.date.year,
      entry.date.month,
      entry.date.day,
    );
    final starnyxEntries = _entriesByStarnyx.putIfAbsent(
      entry.starnyxId,
      () => <DateTime, JournalEntry>{},
    );
    starnyxEntries[normalizedDate] = entry.copyWith(date: normalizedDate);
    _emit(entry.starnyxId);
  }

  @override
  Future<void> deleteJournalEntryByDate({
    required String starnyxId,
    required DateTime date,
  }) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    _entriesByStarnyx[starnyxId]?.remove(normalizedDate);
    _emit(starnyxId);
  }

  @override
  Future<void> deleteJournalEntriesForStarnyx(String starnyxId) async {
    _entriesByStarnyx.remove(starnyxId);
    _emit(starnyxId);
  }

  List<JournalEntry> _sortedEntries(String starnyxId) {
    final list =
        _entriesByStarnyx[starnyxId]?.values.toList() ?? <JournalEntry>[];
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  void _emit(String starnyxId) {
    final controller = _controllers[starnyxId];
    if (controller == null || controller.isClosed) {
      return;
    }
    controller.add(_sortedEntries(starnyxId));
  }
}

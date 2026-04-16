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
        id: 1,
        starnyxId: 's-1',
        date: DateTime(2026, 4, 15),
        content: 'Older note',
        createdAt: DateTime(2026, 4, 15, 10, 0),
      ),
    );
    await repository.saveJournalEntry(
      JournalEntry(
        id: 2,
        starnyxId: 's-1',
        date: DateTime(2026, 4, 16),
        content: 'Today note',
        createdAt: DateTime(2026, 4, 16, 10, 0),
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
    final entries = await repository.getJournalEntriesForStarnyx('s-1');
    expect(entries.first.content, 'Today I completed my habit.');
  });

  test('save allows multiple entries per day', () async {
    await repository.saveJournalEntry(
      JournalEntry(
        id: 1,
        starnyxId: 's-1',
        date: DateTime(2026, 4, 16),
        content: 'Note 1',
        createdAt: DateTime(2026, 4, 16, 9, 0),
      ),
    );
    bloc.add(const JournalStarted('s-1'));
    await pumpEventQueue(times: 3);
    bloc.add(const JournalDraftChanged('Note 2'));
    await pumpEventQueue();

    bloc.add(const JournalSaveRequested());
    await pumpEventQueue(times: 3);

    expect(bloc.state.saveStatus, AsyncStatus.success);
    expect(bloc.state.entries, hasLength(2));
  });

  test('delete removes entry by ID', () async {
    final entry = JournalEntry(
      id: 100,
      starnyxId: 's-1',
      date: DateTime(2026, 4, 16),
      content: 'Delete me',
      createdAt: DateTime(2026, 4, 16, 10, 0),
    );
    await repository.saveJournalEntry(entry);
    
    bloc.add(const JournalStarted('s-1'));
    await pumpEventQueue(times: 3);

    bloc.add(const JournalDeleteRequested(100));
    await pumpEventQueue(times: 5);

    expect(bloc.state.deleteStatus, AsyncStatus.success);
    final entries = await repository.getJournalEntriesForStarnyx('s-1');
    expect(entries.any((e) => e.id == 100), isFalse);
  });
}

class _InMemoryJournalEntryRepository implements JournalEntryRepository {
  final List<JournalEntry> _entries = <JournalEntry>[];
  final Map<String, StreamController<List<JournalEntry>>> _controllers =
      <String, StreamController<List<JournalEntry>>>{};
  int _idCounter = 1000;

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
  Future<List<JournalEntry>> getJournalEntriesForDate({
    required String starnyxId,
    required DateTime date,
  }) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return _entries
        .where((e) => e.starnyxId == starnyxId && e.date == normalizedDate)
        .toList();
  }

  @override
  Future<void> saveJournalEntry(JournalEntry entry) async {
    var toSave = entry;
    if (toSave.id == 0) {
      toSave = toSave.copyWith(id: ++_idCounter);
    }
    _entries.add(toSave);
    _emit(entry.starnyxId);
  }

  @override
  Future<void> deleteJournalEntryById(int id) async {
    final entry = _entries.where((e) => e.id == id).firstOrNull;
    if (entry != null) {
      _entries.removeWhere((e) => e.id == id);
      _emit(entry.starnyxId);
    }
  }

  @override
  Future<void> deleteJournalEntriesForStarnyx(String starnyxId) async {
    _entries.removeWhere((e) => e.starnyxId == starnyxId);
    _emit(starnyxId);
  }

  List<JournalEntry> _sortedEntries(String starnyxId) {
    final list = _entries.where((e) => e.starnyxId == starnyxId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
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

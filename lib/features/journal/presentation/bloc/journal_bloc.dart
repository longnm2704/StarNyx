import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starnyx/core/constants/enums.dart';
import 'package:starnyx/core/utils/date_utils.dart';
import 'package:starnyx/domain/entities/journal_entry.dart';
import 'package:starnyx/domain/usecases/save_journal_entry_use_case.dart';
import 'package:starnyx/domain/usecases/delete_journal_entry_use_case.dart';
import 'package:starnyx/domain/usecases/watch_journal_entries_for_starnyx_use_case.dart';

import 'journal_event.dart';
import 'journal_state.dart';

class JournalBloc extends Bloc<JournalEvent, JournalState> {
  JournalBloc({
    required SaveJournalEntryUseCase saveJournalEntryUseCase,
    required WatchJournalEntriesForStarnyxUseCase
    watchJournalEntriesForStarnyxUseCase,
    required DeleteJournalEntryUseCase deleteJournalEntryUseCase,
    DateTime Function()? nowBuilder,
  }) : _saveJournalEntryUseCase = saveJournalEntryUseCase,
       _watchJournalEntriesForStarnyxUseCase =
           watchJournalEntriesForStarnyxUseCase,
       _deleteJournalEntryUseCase = deleteJournalEntryUseCase,
       _nowBuilder = nowBuilder ?? DateTime.now,
       super(JournalState.initial()) {
    on<JournalStarted>(_onStarted);
    on<JournalDraftChanged>(_onDraftChanged);
    on<JournalSaveRequested>(_onSaveRequested);
    on<JournalDeleteRequested>(_onDeleteRequested);
    on<JournalEntriesChanged>(_onEntriesChanged);
    on<JournalSubscriptionFailed>(_onSubscriptionFailed);
  }

  final SaveJournalEntryUseCase _saveJournalEntryUseCase;
  final WatchJournalEntriesForStarnyxUseCase
  _watchJournalEntriesForStarnyxUseCase;
  final DeleteJournalEntryUseCase _deleteJournalEntryUseCase;
  final DateTime Function() _nowBuilder;

  StreamSubscription<List<JournalEntry>>? _entriesSubscription;

  Future<void> _onStarted(
    JournalStarted event,
    Emitter<JournalState> emit,
  ) async {
    await _entriesSubscription?.cancel();
    emit(
      state.copyWith(
        status: JournalStatus.loading,
        starnyxId: event.starnyxId,
        saveStatus: AsyncStatus.idle,
        deleteStatus: AsyncStatus.idle,
        errorMessage: null,
      ),
    );

    _entriesSubscription =
        _watchJournalEntriesForStarnyxUseCase(event.starnyxId).listen(
          (entries) => add(JournalEntriesChanged(entries)),
          onError: (_) => add(const JournalSubscriptionFailed()),
        );
  }

  void _onDraftChanged(JournalDraftChanged event, Emitter<JournalState> emit) {
    emit(
      state.copyWith(
        draftContent: event.content,
        saveStatus: AsyncStatus.idle,
        deleteStatus: AsyncStatus.idle,
        errorMessage: null,
      ),
    );
  }

  Future<void> _onSaveRequested(
    JournalSaveRequested event,
    Emitter<JournalState> emit,
  ) async {
    final starnyxId = state.starnyxId;
    if (starnyxId == null) {
      return;
    }
    final trimmed = state.draftContent.trim();
    if (trimmed.isEmpty) {
      return;
    }

    emit(
      state.copyWith(
        saveStatus: AsyncStatus.inProgress,
        deleteStatus: AsyncStatus.idle,
        errorMessage: null,
      ),
    );

    try {
      await _saveJournalEntryUseCase(
        starnyxId: starnyxId,
        date: DateUtils.nowDate(_nowBuilder()),
        content: trimmed,
      );
      emit(
        state.copyWith(
          saveStatus: AsyncStatus.success,
          draftContent: '',
          feedbackCount: state.feedbackCount + 1,
          errorMessage: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          saveStatus: AsyncStatus.failure,
          feedbackCount: state.feedbackCount + 1,
          errorMessage:
              'Unable to save the journal entry right now. Please try again.',
        ),
      );
    }
  }

  Future<void> _onDeleteRequested(
    JournalDeleteRequested event,
    Emitter<JournalState> emit,
  ) async {
    emit(
      state.copyWith(
        deleteStatus: AsyncStatus.inProgress,
        saveStatus: AsyncStatus.idle,
        errorMessage: null,
      ),
    );

    try {
      await _deleteJournalEntryUseCase(id: event.id);
      emit(
        state.copyWith(
          deleteStatus: AsyncStatus.success,
          feedbackCount: state.feedbackCount + 1,
          errorMessage: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          deleteStatus: AsyncStatus.failure,
          feedbackCount: state.feedbackCount + 1,
          errorMessage:
              'Unable to delete the journal entry right now. Please try again.',
        ),
      );
    }
  }

  void _onEntriesChanged(
    JournalEntriesChanged event,
    Emitter<JournalState> emit,
  ) {
    emit(state.copyWith(status: JournalStatus.success, entries: event.entries));
  }

  void _onSubscriptionFailed(
    JournalSubscriptionFailed event,
    Emitter<JournalState> emit,
  ) {
    emit(
      state.copyWith(
        status: JournalStatus.failure,
        errorMessage: 'Unable to load journal entries right now.',
      ),
    );
  }

  @override
  Future<void> close() async {
    await _entriesSubscription?.cancel();
    return super.close();
  }
}

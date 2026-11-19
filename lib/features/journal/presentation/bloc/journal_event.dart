import 'package:equatable/equatable.dart';
import 'package:starnyx/domain/entities/journal_entry.dart';

sealed class JournalEvent extends Equatable {
  const JournalEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class JournalStarted extends JournalEvent {
  const JournalStarted(this.starnyxId);

  final String starnyxId;

  @override
  List<Object?> get props => <Object?>[starnyxId];
}

class JournalDraftChanged extends JournalEvent {
  const JournalDraftChanged(this.content);

  final String content;

  @override
  List<Object?> get props => <Object?>[content];
}

class JournalSaveRequested extends JournalEvent {
  const JournalSaveRequested();
}

/// Saves an edit of [entry]; `id` and `createdAt` are preserved.
class JournalEntryUpdated extends JournalEvent {
  const JournalEntryUpdated(this.entry, {required this.content, this.date});

  final JournalEntry entry;
  final String content;
  final DateTime? date;

  @override
  List<Object?> get props => <Object?>[entry, content, date];
}

class JournalDeleteRequested extends JournalEvent {
  const JournalDeleteRequested(this.entry);

  final JournalEntry entry;

  @override
  List<Object?> get props => <Object?>[entry];
}

class JournalDeleteUndoRequested extends JournalEvent {
  const JournalDeleteUndoRequested();
}

class JournalEntriesChanged extends JournalEvent {
  const JournalEntriesChanged(this.entries);

  final List<JournalEntry> entries;

  @override
  List<Object?> get props => <Object?>[entries];
}

class JournalSubscriptionFailed extends JournalEvent {
  const JournalSubscriptionFailed();
}

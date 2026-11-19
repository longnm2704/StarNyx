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

/// Saves the draft as a new entry, with optional metadata from the editor.
class JournalSaveRequested extends JournalEvent {
  const JournalSaveRequested({
    this.mood,
    this.energy,
    this.sleepMinutes,
    this.tags = const <String>[],
  });

  final JournalMood? mood;
  final int? energy;
  final int? sleepMinutes;
  final List<String> tags;

  @override
  List<Object?> get props => <Object?>[mood, energy, sleepMinutes, tags];
}

/// Saves an edit of [entry]; `id` and `createdAt` are preserved. Metadata is
/// replaced with the given values (null clears a field).
class JournalEntryUpdated extends JournalEvent {
  const JournalEntryUpdated(
    this.entry, {
    required this.content,
    this.date,
    this.mood,
    this.energy,
    this.sleepMinutes,
    this.tags = const <String>[],
  });

  final JournalEntry entry;
  final String content;
  final DateTime? date;
  final JournalMood? mood;
  final int? energy;
  final int? sleepMinutes;
  final List<String> tags;

  @override
  List<Object?> get props => <Object?>[
    entry,
    content,
    date,
    mood,
    energy,
    sleepMinutes,
    tags,
  ];
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

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

class JournalDeleteRequested extends JournalEvent {
  const JournalDeleteRequested(this.date);

  final DateTime date;

  @override
  List<Object?> get props => <Object?>[date];
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

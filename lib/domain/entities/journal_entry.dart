import 'package:equatable/equatable.dart';

// Domain object for one daily journal note.
class JournalEntry extends Equatable {
  const JournalEntry({
    required this.starnyxId,
    required this.date,
    required this.content,
  });

  final String starnyxId;
  final DateTime date;
  final String content;

  // Copy helpers keep note edits immutable across bloc states.
  JournalEntry copyWith({String? starnyxId, DateTime? date, String? content}) {
    return JournalEntry(
      starnyxId: starnyxId ?? this.starnyxId,
      date: date ?? this.date,
      content: content ?? this.content,
    );
  }

  @override
  List<Object?> get props => <Object?>[starnyxId, date, content];
}

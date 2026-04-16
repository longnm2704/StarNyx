import 'package:equatable/equatable.dart';

// Domain object for one daily journal note.
class JournalEntry extends Equatable {
  const JournalEntry({
    required this.id,
    required this.starnyxId,
    required this.date,
    required this.content,
    required this.createdAt,
  });

  final int id;
  final String starnyxId;
  final DateTime date;
  final String content;
  final DateTime createdAt;

  // Copy helpers keep note edits immutable across bloc states.
  JournalEntry copyWith({
    int? id,
    String? starnyxId,
    DateTime? date,
    String? content,
    DateTime? createdAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      starnyxId: starnyxId ?? this.starnyxId,
      date: date ?? this.date,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[id, starnyxId, date, content, createdAt];
}

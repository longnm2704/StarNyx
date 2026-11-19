import 'package:equatable/equatable.dart';

/// Mood options offered by the journal editor; stored by [Enum.name].
enum JournalMood { calm, energized, focused, tired }

// Domain object for one daily journal note.
class JournalEntry extends Equatable {
  const JournalEntry({
    required this.id,
    required this.starnyxId,
    required this.date,
    required this.content,
    required this.createdAt,
    this.mood,
    this.energy,
    this.sleepMinutes,
    this.tags = const <String>[],
  });

  static const int minEnergy = 1;
  static const int maxEnergy = 5;
  static const int maxSleepMinutes = 24 * 60;
  static const int maxTags = 10;
  static const int maxTagLength = 32;

  final int id;
  final String starnyxId;
  final DateTime date;
  final String content;
  final DateTime createdAt;

  // Optional reflection metadata (STX-U014).
  final JournalMood? mood;
  final int? energy;
  final int? sleepMinutes;
  final List<String> tags;

  /// Unknown or missing mood keys read as null.
  static JournalMood? moodFromName(String? name) =>
      name == null ? null : JournalMood.values.asNameMap()[name];

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
      mood: mood,
      energy: energy,
      sleepMinutes: sleepMinutes,
      tags: tags,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    starnyxId,
    date,
    content,
    createdAt,
    mood,
    energy,
    sleepMinutes,
    tags,
  ];
}

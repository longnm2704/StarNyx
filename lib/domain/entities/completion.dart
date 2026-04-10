import 'package:equatable/equatable.dart';

// Domain object for one daily completion record.
class Completion extends Equatable {
  const Completion({
    required this.starnyxId,
    required this.date,
    required this.completed,
  });

  final String starnyxId;
  final DateTime date;
  final bool completed;

  // Copy helpers keep toggle and edit flows immutable.
  Completion copyWith({String? starnyxId, DateTime? date, bool? completed}) {
    return Completion(
      starnyxId: starnyxId ?? this.starnyxId,
      date: date ?? this.date,
      completed: completed ?? this.completed,
    );
  }

  @override
  List<Object?> get props => <Object?>[starnyxId, date, completed];
}

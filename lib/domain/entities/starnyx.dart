import 'package:equatable/equatable.dart';

const Object _unset = Object();

// Core domain object for a tracked habit constellation.
class StarNyx extends Equatable {
  const StarNyx({
    required this.id,
    required this.title,
    required this.description,
    required this.color,
    required this.startDate,
    required this.reminderEnabled,
    required this.reminderTime,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String? description;
  final String color;
  final DateTime startDate;
  final bool reminderEnabled;
  final String? reminderTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  // This keeps presentation code from repeating null and blank checks.
  bool get hasDescription => description?.trim().isNotEmpty ?? false;

  // Reminder flows only care when both the flag and time are present.
  bool get hasReminder => reminderEnabled && reminderTime != null;

  // Copy helpers keep entity updates explicit without mutating existing state.
  StarNyx copyWith({
    String? id,
    String? title,
    Object? description = _unset,
    String? color,
    DateTime? startDate,
    bool? reminderEnabled,
    Object? reminderTime = _unset,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StarNyx(
      id: id ?? this.id,
      title: title ?? this.title,
      description: identical(description, _unset)
          ? this.description
          : description as String?,
      color: color ?? this.color,
      startDate: startDate ?? this.startDate,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: identical(reminderTime, _unset)
          ? this.reminderTime
          : reminderTime as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    title,
    description,
    color,
    startDate,
    reminderEnabled,
    reminderTime,
    createdAt,
    updatedAt,
  ];
}

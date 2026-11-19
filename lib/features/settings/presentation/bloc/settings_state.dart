import 'package:equatable/equatable.dart';
import 'package:starnyx/core/constants/enums.dart';
import 'package:starnyx/domain/entities/starnyx.dart';

const Object _unset = Object();

class SettingsState extends Equatable {
  const SettingsState({
    this.exportStatus = AsyncStatus.idle,
    this.importStatus = AsyncStatus.idle,
    this.errorMessage,
    this.exportedFilePath,
    this.starnyxs = const <StarNyx>[],
    this.activeHabitTitle,
    this.currentStreak = 0,
  });

  final AsyncStatus exportStatus;
  final AsyncStatus importStatus;
  final String? errorMessage;
  final String? exportedFilePath;

  /// All habits; drives the reminder row.
  final List<StarNyx> starnyxs;
  final String? activeHabitTitle;
  final int currentStreak;

  /// True when at least one habit reminder is scheduled.
  bool get remindersOn => starnyxs.any((s) => s.hasReminder);

  /// The master switch only makes sense once some habit has a reminder time.
  bool get canToggleReminders => starnyxs.any((s) => s.reminderTime != null);

  /// Next daily reminder (HH:mm) after [now], wrapping to tomorrow's earliest.
  String? nextReminderTime(DateTime now) {
    final times =
        starnyxs
            .where((s) => s.hasReminder)
            .map((s) => s.reminderTime!)
            .toList()
          ..sort();
    if (times.isEmpty) {
      return null;
    }
    final current =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';
    return times.firstWhere(
      (time) => time.compareTo(current) > 0,
      orElse: () => times.first,
    );
  }

  bool get isExporting => exportStatus == AsyncStatus.inProgress;
  bool get hasExportFailure => exportStatus == AsyncStatus.failure;
  bool get hasImportFailure => importStatus == AsyncStatus.failure;

  SettingsState copyWith({
    AsyncStatus? exportStatus,
    AsyncStatus? importStatus,
    Object? errorMessage = _unset,
    Object? exportedFilePath = _unset,
    List<StarNyx>? starnyxs,
    Object? activeHabitTitle = _unset,
    int? currentStreak,
  }) {
    return SettingsState(
      exportStatus: exportStatus ?? this.exportStatus,
      importStatus: importStatus ?? this.importStatus,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      exportedFilePath: identical(exportedFilePath, _unset)
          ? this.exportedFilePath
          : exportedFilePath as String?,
      starnyxs: starnyxs ?? this.starnyxs,
      activeHabitTitle: identical(activeHabitTitle, _unset)
          ? this.activeHabitTitle
          : activeHabitTitle as String?,
      currentStreak: currentStreak ?? this.currentStreak,
    );
  }

  @override
  List<Object?> get props => [
    exportStatus,
    importStatus,
    errorMessage,
    exportedFilePath,
    starnyxs,
    activeHabitTitle,
    currentStreak,
  ];
}

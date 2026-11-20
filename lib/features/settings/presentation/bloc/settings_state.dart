import 'package:equatable/equatable.dart';
import 'package:starnyx/core/constants/enums.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/entities/storage_stats.dart';

const Object _unset = Object();

class SettingsState extends Equatable {
  const SettingsState({
    this.exportStatus = AsyncStatus.idle,
    this.importStatus = AsyncStatus.idle,
    this.exportedFilePath,
    this.starnyxs = const <StarNyx>[],
    this.activeHabitTitle,
    this.currentStreak = 0,
    this.storage,
    this.deleteAllStatus = AsyncStatus.idle,
    this.notificationsAllowed = true,
    this.remindersToggleFailureCount = 0,
  });

  final AsyncStatus exportStatus;
  final AsyncStatus importStatus;
  final String? exportedFilePath;

  /// All habits; drives the reminder row.
  final List<StarNyx> starnyxs;
  final String? activeHabitTitle;
  final int currentStreak;

  /// Null until the backup screen loads it.
  final StorageStats? storage;
  final AsyncStatus deleteAllStatus;

  /// False when the OS blocks notifications: reminders are on but won't show.
  final bool notificationsAllowed;

  /// Bumped on each failed master-switch toggle (snackbar trigger).
  final int remindersToggleFailureCount;

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
    Object? exportedFilePath = _unset,
    List<StarNyx>? starnyxs,
    Object? activeHabitTitle = _unset,
    int? currentStreak,
    StorageStats? storage,
    AsyncStatus? deleteAllStatus,
    bool? notificationsAllowed,
    int? remindersToggleFailureCount,
  }) {
    return SettingsState(
      exportStatus: exportStatus ?? this.exportStatus,
      importStatus: importStatus ?? this.importStatus,
      exportedFilePath: identical(exportedFilePath, _unset)
          ? this.exportedFilePath
          : exportedFilePath as String?,
      starnyxs: starnyxs ?? this.starnyxs,
      activeHabitTitle: identical(activeHabitTitle, _unset)
          ? this.activeHabitTitle
          : activeHabitTitle as String?,
      currentStreak: currentStreak ?? this.currentStreak,
      storage: storage ?? this.storage,
      deleteAllStatus: deleteAllStatus ?? this.deleteAllStatus,
      notificationsAllowed: notificationsAllowed ?? this.notificationsAllowed,
      remindersToggleFailureCount:
          remindersToggleFailureCount ?? this.remindersToggleFailureCount,
    );
  }

  @override
  List<Object?> get props => [
    exportStatus,
    importStatus,
    exportedFilePath,
    starnyxs,
    activeHabitTitle,
    currentStreak,
    storage,
    deleteAllStatus,
    notificationsAllowed,
    remindersToggleFailureCount,
  ];
}

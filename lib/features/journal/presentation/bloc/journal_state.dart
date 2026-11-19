import 'package:equatable/equatable.dart';
import 'package:starnyx/core/constants/enums.dart';
import 'package:starnyx/domain/entities/journal_entry.dart';

const Object _unset = Object();

class JournalState extends Equatable {
  const JournalState({
    required this.status,
    required this.starnyxId,
    required this.entries,
    required this.draftContent,
    required this.saveStatus,
    required this.updateStatus,
    required this.deleteStatus,
    required this.undoDeleteStatus,
    required this.recentlyDeletedEntry,
    required this.feedbackCount,
  });

  factory JournalState.initial() {
    return const JournalState(
      status: JournalStatus.initial,
      starnyxId: null,
      entries: <JournalEntry>[],
      draftContent: '',
      saveStatus: AsyncStatus.idle,
      updateStatus: AsyncStatus.idle,
      deleteStatus: AsyncStatus.idle,
      undoDeleteStatus: AsyncStatus.idle,
      recentlyDeletedEntry: null,
      feedbackCount: 0,
    );
  }

  final JournalStatus status;
  final String? starnyxId;
  final List<JournalEntry> entries;
  final String draftContent;
  final AsyncStatus saveStatus;
  final AsyncStatus updateStatus;
  final AsyncStatus deleteStatus;
  final AsyncStatus undoDeleteStatus;
  final JournalEntry? recentlyDeletedEntry;
  final int feedbackCount;

  bool get hasStarnyx => (starnyxId ?? '').isNotEmpty;
  bool get canSaveDraft =>
      hasStarnyx &&
      saveStatus != AsyncStatus.inProgress &&
      draftContent.trim().isNotEmpty;

  JournalState copyWith({
    JournalStatus? status,
    Object? starnyxId = _unset,
    List<JournalEntry>? entries,
    String? draftContent,
    AsyncStatus? saveStatus,
    AsyncStatus? updateStatus,
    AsyncStatus? deleteStatus,
    AsyncStatus? undoDeleteStatus,
    Object? recentlyDeletedEntry = _unset,
    int? feedbackCount,
  }) {
    return JournalState(
      status: status ?? this.status,
      starnyxId: identical(starnyxId, _unset)
          ? this.starnyxId
          : starnyxId as String?,
      entries: entries ?? this.entries,
      draftContent: draftContent ?? this.draftContent,
      saveStatus: saveStatus ?? this.saveStatus,
      updateStatus: updateStatus ?? this.updateStatus,
      deleteStatus: deleteStatus ?? this.deleteStatus,
      undoDeleteStatus: undoDeleteStatus ?? this.undoDeleteStatus,
      recentlyDeletedEntry: identical(recentlyDeletedEntry, _unset)
          ? this.recentlyDeletedEntry
          : recentlyDeletedEntry as JournalEntry?,
      feedbackCount: feedbackCount ?? this.feedbackCount,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    starnyxId,
    entries,
    draftContent,
    saveStatus,
    updateStatus,
    deleteStatus,
    undoDeleteStatus,
    recentlyDeletedEntry,
    feedbackCount,
  ];
}

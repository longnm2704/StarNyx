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
    required this.deleteStatus,
    required this.feedbackCount,
    required this.errorMessage,
  });

  factory JournalState.initial() {
    return const JournalState(
      status: JournalStatus.initial,
      starnyxId: null,
      entries: <JournalEntry>[],
      draftContent: '',
      saveStatus: AsyncStatus.idle,
      deleteStatus: AsyncStatus.idle,
      feedbackCount: 0,
      errorMessage: null,
    );
  }

  final JournalStatus status;
  final String? starnyxId;
  final List<JournalEntry> entries;
  final String draftContent;
  final AsyncStatus saveStatus;
  final AsyncStatus deleteStatus;
  final int feedbackCount;
  final String? errorMessage;

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
    AsyncStatus? deleteStatus,
    int? feedbackCount,
    Object? errorMessage = _unset,
  }) {
    return JournalState(
      status: status ?? this.status,
      starnyxId: identical(starnyxId, _unset)
          ? this.starnyxId
          : starnyxId as String?,
      entries: entries ?? this.entries,
      draftContent: draftContent ?? this.draftContent,
      saveStatus: saveStatus ?? this.saveStatus,
      deleteStatus: deleteStatus ?? this.deleteStatus,
      feedbackCount: feedbackCount ?? this.feedbackCount,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    starnyxId,
    entries,
    draftContent,
    saveStatus,
    deleteStatus,
    feedbackCount,
    errorMessage,
  ];
}

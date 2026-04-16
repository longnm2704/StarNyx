import 'package:equatable/equatable.dart';
import 'package:starnyx/core/constants/enums.dart';
import 'package:starnyx/domain/entities/starnyx.dart';

/// Sentinel object used in copyWith() to distinguish null values from unmodified fields.
const Object _unset = Object();

/// Represents the complete state of the StarNyx form.
///
/// The form manages both user input (title, description, etc.) and validation state,
/// allowing the UI to disable the submit button and display error messages.
///
/// When submission succeeds, [savedStarnyx] is populated with the created/updated entity,
/// allowing the UI to navigate away or update parent widgets.
class StarnyxFormState extends Equatable {
  const StarnyxFormState({
    required this.mode,
    required this.title,
    required this.description,
    required this.color,
    required this.startDate,
    required this.reminderEnabled,
    required this.reminderTime,
    required this.titleError,
    required this.descriptionError,
    required this.startDateError,
    required this.reminderTimeError,
    required this.submissionStatus,
    required this.savedStarnyx,
    required this.submissionErrorMessage,
    required this.deletionStatus,
    required this.deletedStarnyxId,
    required this.deletionErrorMessage,
  });

  /// Whether the form is creating a new StarNyx or editing an existing one.
  final StarnyxFormMode mode;

  /// User-entered title text (validated: not empty after trim).
  final String title;

  /// User-entered description text (optional).
  final String description;

  /// Selected color as a hex string (e.g., '#8E5BFF').
  final String color;

  /// Selected start date (validated: not in the future).
  final DateTime startDate;

  /// Whether the reminder is enabled.
  final bool reminderEnabled;

  /// Reminder time in HH:mm format (validated when reminder is enabled).
  final String reminderTime;

  /// Validation error for title (non-null if invalid).
  final StarnyxFormTitleError? titleError;

  /// Validation error for description (non-null if invalid).
  final StarnyxFormDescriptionError? descriptionError;

  /// Validation error for start date (non-null if invalid).
  final StarnyxFormStartDateError? startDateError;

  /// Validation error for reminder time (non-null if invalid).
  final StarnyxFormReminderTimeError? reminderTimeError;

  /// Current stage of the form submission process.
  final AsyncStatus submissionStatus;

  /// The successfully saved StarNyx entity (only populated after successful submission).
  final StarNyx? savedStarnyx;

  /// Human-readable error message from failed submission (from use case exception).
  final String? submissionErrorMessage;

  /// Current stage of the delete process.
  final AsyncStatus deletionStatus;

  /// Deleted StarNyx id when the delete action succeeds.
  final String? deletedStarnyxId;

  /// Human-readable error message from failed deletion.
  final String? deletionErrorMessage;

  /// Convenience getter: true if form is in edit mode.
  bool get isEditing => mode == StarnyxFormMode.edit;

  /// Convenience getter: true if any field has a validation error.
  /// Used to disable the submit button.
  bool get hasValidationErrors =>
      titleError != null ||
      descriptionError != null ||
      startDateError != null ||
      reminderTimeError != null;

  /// Convenience getter: true if the form can be submitted (all validations pass and no request in flight).
  /// UI uses this to enable/disable the submit button.
  bool get canSubmit =>
      submissionStatus != AsyncStatus.inProgress &&
      deletionStatus != AsyncStatus.inProgress &&
      !hasValidationErrors &&
      title.trim().isNotEmpty;

  /// Convenience getter: true if delete action can run.
  bool get canDelete => isEditing && deletionStatus != AsyncStatus.inProgress;

  /// Creates a new state with specified fields replaced.
  /// Uses [_unset] sentinel to distinguish null from unmodified, enabling nullable fields to be explicitly set to null.
  /// This is necessary because the form supports optional fields like description and reminderTime.
  StarnyxFormState copyWith({
    StarnyxFormMode? mode,
    String? title,
    String? description,
    String? color,
    DateTime? startDate,
    bool? reminderEnabled,
    String? reminderTime,
    Object? titleError = _unset,
    Object? descriptionError = _unset,
    Object? startDateError = _unset,
    Object? reminderTimeError = _unset,
    AsyncStatus? submissionStatus,
    Object? savedStarnyx = _unset,
    Object? submissionErrorMessage = _unset,
    AsyncStatus? deletionStatus,
    Object? deletedStarnyxId = _unset,
    Object? deletionErrorMessage = _unset,
  }) {
    return StarnyxFormState(
      mode: mode ?? this.mode,
      title: title ?? this.title,
      description: description ?? this.description,
      color: color ?? this.color,
      startDate: startDate ?? this.startDate,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      titleError: identical(titleError, _unset)
          ? this.titleError
          : titleError as StarnyxFormTitleError?,
      descriptionError: identical(descriptionError, _unset)
          ? this.descriptionError
          : descriptionError as StarnyxFormDescriptionError?,
      startDateError: identical(startDateError, _unset)
          ? this.startDateError
          : startDateError as StarnyxFormStartDateError?,
      reminderTimeError: identical(reminderTimeError, _unset)
          ? this.reminderTimeError
          : reminderTimeError as StarnyxFormReminderTimeError?,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      savedStarnyx: identical(savedStarnyx, _unset)
          ? this.savedStarnyx
          : savedStarnyx as StarNyx?,
      submissionErrorMessage: identical(submissionErrorMessage, _unset)
          ? this.submissionErrorMessage
          : submissionErrorMessage as String?,
      deletionStatus: deletionStatus ?? this.deletionStatus,
      deletedStarnyxId: identical(deletedStarnyxId, _unset)
          ? this.deletedStarnyxId
          : deletedStarnyxId as String?,
      deletionErrorMessage: identical(deletionErrorMessage, _unset)
          ? this.deletionErrorMessage
          : deletionErrorMessage as String?,
    );
  }

  /// All properties used for structural equality via Equatable.
  /// Immutable form states are considered equal if all fields match.

  @override
  List<Object?> get props => <Object?>[
    mode,
    title,
    description,
    color,
    startDate,
    reminderEnabled,
    reminderTime,
    titleError,
    descriptionError,
    startDateError,
    reminderTimeError,
    submissionStatus,
    savedStarnyx,
    submissionErrorMessage,
    deletionStatus,
    deletedStarnyxId,
    deletionErrorMessage,
  ];
}

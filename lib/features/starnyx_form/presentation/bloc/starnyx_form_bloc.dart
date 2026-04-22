import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starnyx/core/utils/core_utils.dart';
import 'package:starnyx/core/constants/core_constants.dart';
import 'package:starnyx/domain/entities/domain_entities.dart';
import 'package:starnyx/domain/usecases/domain_usecases.dart';

import 'starnyx_form_event.dart';
import 'starnyx_form_state.dart';

const int _maxStarnyxTitleLength = 60;
const int _maxStarnyxDescriptionLength = 160;

/// BLoC that manages the state and business logic for creating and editing StarNyx entities.
///
/// The BLoC handles:
/// - Field-level validation (title, start date, reminder time)
/// - Submission logic (delegating to use cases)
/// - Use case error mapping
/// - State transitions (idle → inProgress → success/failure)
///
/// The BLoC can be instantiated in two modes:
/// 1. **Create mode**: No initial StarNyx provided, starts with empty form
/// 2. **Edit mode**: StarNyx provided, prefills all fields from the entity
///
class StarnyxFormBloc extends Bloc<StarnyxFormEvent, StarnyxFormState> {
  static const int maxTitleLength = _maxStarnyxTitleLength;
  static const int maxDescriptionLength = _maxStarnyxDescriptionLength;

  /// Creates a new StarnyxFormBloc instance.
  ///
  /// Parameters:
  /// - [createStarNyxUseCase]: Service to persist new StarNyx entities
  /// - [updateStarNyxUseCase]: Service to update existing StarNyx entities
  /// - [nowBuilder]: Callback to get the current date/time (injectable for testing)
  /// - [initialStarnyx]: If provided, form starts in edit mode; otherwise creates new
  StarnyxFormBloc({
    required CreateStarNyxUseCase createStarNyxUseCase,
    required UpdateStarNyxUseCase updateStarNyxUseCase,
    required DeleteStarNyxUseCase deleteStarNyxUseCase,
    required SyncNotificationsUseCase syncNotificationsUseCase,
    DateTime Function()? nowBuilder,
    StarNyx? initialStarnyx,
    String? initialColor,
  }) : _createStarNyxUseCase = createStarNyxUseCase,
       _updateStarNyxUseCase = updateStarNyxUseCase,
       _deleteStarNyxUseCase = deleteStarNyxUseCase,
       _syncNotificationsUseCase = syncNotificationsUseCase,
       _nowBuilder = nowBuilder ?? DateTime.now,
       _initialStarnyx = initialStarnyx,
       super(_buildInitialState(initialStarnyx, (nowBuilder ?? DateTime.now)(), initialColor)) {
    // Register event handlers for each event type using on<T>() pattern
    on<StarnyxFormTitleChanged>(_onTitleChanged);
    on<StarnyxFormDescriptionChanged>(_onDescriptionChanged);
    on<StarnyxFormColorChanged>(_onColorChanged);
    on<StarnyxFormStartDateChanged>(_onStartDateChanged);
    on<StarnyxFormReminderToggled>(_onReminderToggled);
    on<StarnyxFormReminderTimeChanged>(_onReminderTimeChanged);
    on<StarnyxFormSubmitted>(_onSubmitted);
    on<StarnyxFormDeleted>(_onDeleted);
  }

  /// Injected use case for creating new StarNyx entities.
  final CreateStarNyxUseCase _createStarNyxUseCase;

  /// Injected use case for updating existing StarNyx entities.
  final UpdateStarNyxUseCase _updateStarNyxUseCase;

  /// Injected use case for deleting existing StarNyx entities.
  final DeleteStarNyxUseCase _deleteStarNyxUseCase;

  /// Synchronizes notification schedules after StarNyx changes.
  final SyncNotificationsUseCase _syncNotificationsUseCase;

  /// Callback to get current date/time (injectable for testing time-dependent logic).
  final DateTime Function() _nowBuilder;

  /// The initial StarNyx entity when in edit mode (null when in create mode).
  final StarNyx? _initialStarnyx;

  /// Builds the initial state for the form based on mode.
  ///
  /// For **edit mode** (when [initialStarnyx] is provided):
  /// - Prefills all fields from the existing entity
  /// - Sets validation errors to null since existing data is assumed valid
  ///
  /// For **create mode** (when [initialStarnyx] is null):
  /// - Starts with empty title and description
  /// - Sets start date to today
  /// - Reminder defaults to disabled but suggests the current time as HH:mm
  /// - Shows title validation error (empty) to prompt user input
  static StarnyxFormState _buildInitialState(
    StarNyx? initialStarnyx,
    DateTime now,
    String? initialColor,
  ) {
    if (initialStarnyx != null) {
      return StarnyxFormState(
        mode: StarnyxFormMode.edit,
        title: initialStarnyx.title,
        description: initialStarnyx.description ?? '',
        color: initialStarnyx.color,
        startDate: initialStarnyx.startDate,
        reminderEnabled: initialStarnyx.reminderEnabled,
        reminderTime: initialStarnyx.reminderTime ?? '',
        titleError: null,
        descriptionError: null,
        startDateError: null,
        reminderTimeError: null,
        submissionStatus: AsyncStatus.idle,
        savedStarnyx: null,
        submissionErrorMessage: null,
        deletionStatus: AsyncStatus.idle,
        deletedStarnyxId: null,
        deletionErrorMessage: null,
      );
    }

    final defaultReminder = ReminderTimeUtils.formatTime(now);

    return StarnyxFormState(
      mode: StarnyxFormMode.create,
      title: '',
      description: '',
      color: initialColor ?? AppColors.starnyxPresetColorHexes.first,
      startDate: DateUtils.nowDate(now),
      reminderEnabled: false,
      reminderTime: defaultReminder,
      titleError: StarnyxFormTitleError.empty,
      descriptionError: null,
      startDateError: null,
      reminderTimeError: null,
      submissionStatus: AsyncStatus.idle,
      savedStarnyx: null,
      submissionErrorMessage: null,
      deletionStatus: AsyncStatus.idle,
      deletedStarnyxId: null,
      deletionErrorMessage: null,
    );
  }

  /// Handles title field changes.
  ///
  /// Always re-validates the form when title changes because:
  /// - It's the only required field
  /// - User needs immediate feedback when typing
  void _onTitleChanged(
    StarnyxFormTitleChanged event,
    Emitter<StarnyxFormState> emit,
  ) {
    _emitFieldChange(
      emit,
      state.copyWith(title: event.title),
      revalidate: true,
    );
  }

  /// Handles description field changes.
  /// Description is optional, but still has a max-length validation.
  void _onDescriptionChanged(
    StarnyxFormDescriptionChanged event,
    Emitter<StarnyxFormState> emit,
  ) {
    _emitFieldChange(
      emit,
      state.copyWith(description: event.description),
      revalidate: true,
    );
  }

  /// Handles color field changes.
  /// Color selection doesn't affect validation (any color is valid).
  void _onColorChanged(
    StarnyxFormColorChanged event,
    Emitter<StarnyxFormState> emit,
  ) {
    _emitFieldChange(emit, state.copyWith(color: event.color));
  }

  /// Handles start date field changes.
  /// Revalidates because start date must not be in the future.
  void _onStartDateChanged(
    StarnyxFormStartDateChanged event,
    Emitter<StarnyxFormState> emit,
  ) {
    _emitFieldChange(
      emit,
      state.copyWith(startDate: event.startDate),
      revalidate: true,
    );
  }

  /// Handles reminder toggle.
  /// When toggled on, the form validates that a time is provided.
  /// When toggled off, reminder time validation is skipped.
  void _onReminderToggled(
    StarnyxFormReminderToggled event,
    Emitter<StarnyxFormState> emit,
  ) {
    _emitFieldChange(
      emit,
      state.copyWith(reminderEnabled: event.enabled),
      revalidate: true,
    );
  }

  /// Handles reminder time field changes.
  /// Revalidates because time is required when reminder is enabled.
  void _onReminderTimeChanged(
    StarnyxFormReminderTimeChanged event,
    Emitter<StarnyxFormState> emit,
  ) {
    _emitFieldChange(
      emit,
      state.copyWith(reminderTime: event.reminderTime),
      revalidate: true,
    );
  }

  /// Handles form submission (Create or Update).
  ///
  /// Process:
  /// 1. Validates all fields; if invalid, emits error state and returns early
  /// 2. Sets submissionStatus to inProgress and clears previous errors
  /// 3. Calls appropriate use case (create or update) with trimmed/normalized data
  /// 4. On success: emits success state with the saved entity
  /// 5. On UseCaseValidationException: maps error code to field errors and displays message
  /// 6. On other exceptions: displays generic error message
  ///
  /// The returned [StarNyx] entity can be used by the UI to navigate away from the form.
  Future<void> _onSubmitted(
    StarnyxFormSubmitted event,
    Emitter<StarnyxFormState> emit,
  ) async {
    final validated = _validatedState(state);
    if (!validated.canSubmit) {
      emit(validated);
      return;
    }

    emit(
      validated.copyWith(
        submissionStatus: AsyncStatus.inProgress,
        submissionErrorMessage: null,
        savedStarnyx: null,
        deletionErrorMessage: null,
        deletedStarnyxId: null,
      ),
    );

    try {
      final description = _normalizedDescription(validated.description);
      final reminderTime = validated.reminderEnabled
          ? validated.reminderTime.trim()
          : null;
      final now = _nowBuilder();

      final saved = validated.isEditing
          ? await _updateStarNyxUseCase(
              _initialStarnyx!.copyWith(
                title: validated.title.trim(),
                description: description,
                color: validated.color,
                startDate: validated.startDate,
                reminderEnabled: validated.reminderEnabled,
                reminderTime: reminderTime,
              ),
              now: now,
            )
          : await _createStarNyxUseCase(
              title: validated.title.trim(),
              description: description,
              color: validated.color,
              startDate: validated.startDate,
              reminderEnabled: validated.reminderEnabled,
              reminderTime: reminderTime,
              now: now,
            );
      await _syncNotificationsUseCase.onStarnyxSaved(saved);

      emit(
        validated.copyWith(
          submissionStatus: AsyncStatus.success,
          savedStarnyx: saved,
          submissionErrorMessage: null,
          deletionErrorMessage: null,
        ),
      );
    } on UseCaseValidationException catch (error) {
      emit(
        _applyUseCaseValidation(validated, error).copyWith(
          submissionStatus: AsyncStatus.failure,
          submissionErrorMessage: error.message,
          savedStarnyx: null,
          deletionErrorMessage: null,
        ),
      );
    } catch (_) {
      emit(
        validated.copyWith(
          submissionStatus: AsyncStatus.failure,
          submissionErrorMessage:
              'Unable to save the StarNyx right now. Please try again.',
          savedStarnyx: null,
          deletionErrorMessage: null,
        ),
      );
    }
  }

  Future<void> _onDeleted(
    StarnyxFormDeleted event,
    Emitter<StarnyxFormState> emit,
  ) async {
    if (_initialStarnyx == null || !state.isEditing) {
      return;
    }

    emit(
      state.copyWith(
        deletionStatus: AsyncStatus.inProgress,
        deletionErrorMessage: null,
        deletedStarnyxId: null,
        submissionErrorMessage: null,
        savedStarnyx: null,
      ),
    );

    try {
      await _deleteStarNyxUseCase(_initialStarnyx.id, now: _nowBuilder());
      await _syncNotificationsUseCase.onStarnyxDeleted(_initialStarnyx.id);
      emit(
        state.copyWith(
          deletionStatus: AsyncStatus.success,
          deletedStarnyxId: _initialStarnyx.id,
          deletionErrorMessage: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          deletionStatus: AsyncStatus.failure,
          deletionErrorMessage:
              'Unable to delete the StarNyx right now. Please try again.',
        ),
      );
    }
  }

  /// Emits a field change with optional revalidation.
  /// Always resets submission status when a field changes (clearing previous errors).
  void _emitFieldChange(
    Emitter<StarnyxFormState> emit,
    StarnyxFormState candidate, {
    bool revalidate = false,
  }) {
    final nextState = revalidate ? _validatedState(candidate) : candidate;
    emit(_resetSubmissionState(nextState));
  }

  /// Resets submission status when user modifies a field.
  /// Clears success/failure state so the submit button can be re-engaged.
  StarnyxFormState _resetSubmissionState(StarnyxFormState candidate) {
    return candidate.copyWith(
      submissionStatus: AsyncStatus.idle,
      submissionErrorMessage: null,
      savedStarnyx: null,
      deletionStatus: AsyncStatus.idle,
      deletedStarnyxId: null,
      deletionErrorMessage: null,
    );
  }

  /// Validates all form fields and returns a state with validation errors.
  ///
  /// Validation rules:
  /// - **Title**: Required (cannot be empty after trim)
  /// - **Title**: Maximum 60 characters after trim
  /// - **Description**: Optional, maximum 160 characters after trim
  /// - **Start date**: Must be within the last 7 days and not in the future
  /// - **Reminder time**: Required if reminder is enabled, must be valid HH:mm format
  StarnyxFormState _validatedState(StarnyxFormState candidate) {
    final trimmedTitle = candidate.title.trim();
    final trimmedDescription = candidate.description.trim();
    final titleError = trimmedTitle.isEmpty
        ? StarnyxFormTitleError.empty
        : trimmedTitle.length > _maxStarnyxTitleLength
        ? StarnyxFormTitleError.tooLong
        : null;
    final descriptionError =
        trimmedDescription.length > _maxStarnyxDescriptionLength
        ? StarnyxFormDescriptionError.tooLong
        : null;
    final today = DateUtils.nowDate(_nowBuilder());
    final earliestAllowedDate = today.subtract(const Duration(days: 7));
    final normalizedStartDate = DateUtils.dateOnly(candidate.startDate);
    final startDateError = normalizedStartDate.isAfter(today)
        ? StarnyxFormStartDateError.inFuture
        : normalizedStartDate.isBefore(earliestAllowedDate)
        ? StarnyxFormStartDateError.tooFarInPast
        : null;
    final reminderTimeError = _reminderTimeErrorFor(candidate);

    return candidate.copyWith(
      titleError: titleError,
      descriptionError: descriptionError,
      startDateError: startDateError,
      reminderTimeError: reminderTimeError,
    );
  }

  /// Maps use case validation exceptions to form field errors.
  /// Called when the use case detects a business logic violation during submission.
  /// This allows the use case to reject data that passed client-side validation.
  StarnyxFormState _applyUseCaseValidation(
    StarnyxFormState candidate,
    UseCaseValidationException error,
  ) {
    return switch (error.code) {
      UseCaseValidationCode.startDateInFuture => candidate.copyWith(
        startDateError: StarnyxFormStartDateError.inFuture,
      ),
      UseCaseValidationCode.startDateTooFarInPast => candidate.copyWith(
        startDateError: StarnyxFormStartDateError.tooFarInPast,
      ),
      _ => candidate,
    };
  }

  /// Determines if reminder time is valid based on current form state.
  ///
  /// Returns null if no error (validation passed).
  /// Returns [StarnyxFormReminderTimeError.missing] if reminder is enabled but time is empty.
  /// Returns [StarnyxFormReminderTimeError.invalid] if time format is invalid.
  StarnyxFormReminderTimeError? _reminderTimeErrorFor(
    StarnyxFormState candidate,
  ) {
    if (!candidate.reminderEnabled) {
      return null;
    }

    final trimmed = candidate.reminderTime.trim();
    if (trimmed.isEmpty) {
      return StarnyxFormReminderTimeError.missing;
    }

    if (!ReminderTimeUtils.isValidTimeString(trimmed)) {
      return StarnyxFormReminderTimeError.invalid;
    }

    return null;
  }

  /// Normalizes description by trimming whitespace.
  /// Returns null if description is empty (consistent with domain layer expectations).
  String? _normalizedDescription(String description) {
    final trimmed = description.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

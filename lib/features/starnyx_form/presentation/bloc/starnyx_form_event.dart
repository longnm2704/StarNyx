import 'package:equatable/equatable.dart';

/// Base class for all StarNyx form events.
/// Uses sealed class to enable exhaustive pattern matching on event types.
/// All events are immutable and implement Equatable for value comparison.
sealed class StarnyxFormEvent extends Equatable {
  const StarnyxFormEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

/// Triggered when the form title field changes.
/// The UI should emit this event on every keystroke to enable real-time validation.
final class StarnyxFormTitleChanged extends StarnyxFormEvent {
  const StarnyxFormTitleChanged(this.title);

  /// The updated title text (may be empty or contain whitespace).
  final String title;

  @override
  List<Object?> get props => <Object?>[title];
}

/// Triggered when the form description field changes.
/// Description is optional and does not trigger revalidation.
final class StarnyxFormDescriptionChanged extends StarnyxFormEvent {
  const StarnyxFormDescriptionChanged(this.description);

  /// The updated description text (may be empty).
  final String description;

  @override
  List<Object?> get props => <Object?>[description];
}

/// Triggered when the user selects a different color from the color picker.
/// Color should be stored as a hex string (#RRGGBB format).
final class StarnyxFormColorChanged extends StarnyxFormEvent {
  const StarnyxFormColorChanged(this.color);

  /// The selected color as a hex string (e.g., '#8E5BFF').
  final String color;

  @override
  List<Object?> get props => <Object?>[color];
}

/// Triggered when the user selects a different start date.
/// Start date is validated to prevent future dates.
final class StarnyxFormStartDateChanged extends StarnyxFormEvent {
  const StarnyxFormStartDateChanged(this.startDate);

  /// The selected start date (typically the "today" reference, not future dates).
  final DateTime startDate;

  @override
  List<Object?> get props => <Object?>[startDate];
}

/// Triggered when the reminder toggle switch is toggled on/off.
/// Enabling reminder requires the user to set a valid time.
final class StarnyxFormReminderToggled extends StarnyxFormEvent {
  const StarnyxFormReminderToggled(this.enabled);

  /// Whether reminders are enabled or disabled.
  final bool enabled;

  @override
  List<Object?> get props => <Object?>[enabled];
}

/// Triggered when the reminder time is changed via time picker.
/// Time should be in HH:mm format.
final class StarnyxFormReminderTimeChanged extends StarnyxFormEvent {
  const StarnyxFormReminderTimeChanged(this.reminderTime);

  /// The selected reminder time in HH:mm format (e.g., '09:30').
  final String reminderTime;

  @override
  List<Object?> get props => <Object?>[reminderTime];
}

/// Triggered when the user taps the submit button (Create or Update).
/// The BLoC validates all fields before calling use cases.
/// Returns success/failure status and saved entity if successful.
final class StarnyxFormSubmitted extends StarnyxFormEvent {
  const StarnyxFormSubmitted();
}

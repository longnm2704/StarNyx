import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class SettingsExportRequested extends SettingsEvent {
  const SettingsExportRequested({this.passphrase});

  final String? passphrase;

  @override
  List<Object?> get props => [passphrase];
}

class SettingsImportRequested extends SettingsEvent {
  const SettingsImportRequested(this.jsonPayload);

  final Map<String, dynamic> jsonPayload;

  @override
  List<Object?> get props => [jsonPayload];
}

/// Loads the live data the Settings tab shows (active habit, streak, reminders).
class SettingsSummaryRequested extends SettingsEvent {
  const SettingsSummaryRequested();
}

/// Master reminder switch: turns every habit reminder on or off.
class SettingsRemindersToggled extends SettingsEvent {
  const SettingsRemindersToggled(this.enabled);

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

/// Loads database size and row counts for the backup screen.
class SettingsStorageRequested extends SettingsEvent {
  const SettingsStorageRequested();
}

/// Irreversibly wipes all local data (already confirmed by the user).
class SettingsDeleteAllRequested extends SettingsEvent {
  const SettingsDeleteAllRequested();
}

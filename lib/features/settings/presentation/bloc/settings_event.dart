import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class SettingsExportRequested extends SettingsEvent {
  const SettingsExportRequested();
}

class SettingsImportRequested extends SettingsEvent {
  const SettingsImportRequested(this.jsonPayload);

  final Map<String, dynamic> jsonPayload;

  @override
  List<Object?> get props => [jsonPayload];
}

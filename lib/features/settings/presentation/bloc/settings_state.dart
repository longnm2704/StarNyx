import 'package:equatable/equatable.dart';
import 'package:starnyx/core/constants/enums.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.exportStatus = AsyncStatus.idle,
    this.importStatus = AsyncStatus.idle,
    this.errorMessage,
  });

  final AsyncStatus exportStatus;
  final AsyncStatus importStatus;
  final String? errorMessage;

  SettingsState copyWith({
    AsyncStatus? exportStatus,
    AsyncStatus? importStatus,
    String? errorMessage,
  }) {
    return SettingsState(
      exportStatus: exportStatus ?? this.exportStatus,
      importStatus: importStatus ?? this.importStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [exportStatus, importStatus, errorMessage];
}

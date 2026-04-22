import 'package:equatable/equatable.dart';
import 'package:starnyx/core/constants/enums.dart';

const Object _unset = Object();

class SettingsState extends Equatable {
  const SettingsState({
    this.exportStatus = AsyncStatus.idle,
    this.importStatus = AsyncStatus.idle,
    this.errorMessage,
    this.exportedFilePath,
  });

  final AsyncStatus exportStatus;
  final AsyncStatus importStatus;
  final String? errorMessage;
  final String? exportedFilePath;

  bool get isExporting => exportStatus == AsyncStatus.inProgress;
  bool get hasExportFailure => exportStatus == AsyncStatus.failure;
  bool get hasImportFailure => importStatus == AsyncStatus.failure;

  SettingsState copyWith({
    AsyncStatus? exportStatus,
    AsyncStatus? importStatus,
    Object? errorMessage = _unset,
    Object? exportedFilePath = _unset,
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
    );
  }

  @override
  List<Object?> get props => [
    exportStatus,
    importStatus,
    errorMessage,
    exportedFilePath,
  ];
}

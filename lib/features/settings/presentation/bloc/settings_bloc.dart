import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:starnyx/core/constants/enums.dart';
import 'package:starnyx/domain/usecases/export_data_use_case.dart';
import 'package:starnyx/domain/usecases/import_data_use_case.dart';
import 'package:starnyx/domain/usecases/sync_notifications_use_case.dart';

import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    required ExportDataUseCase exportDataUseCase,
    required ImportDataUseCase importDataUseCase,
    required SyncNotificationsUseCase syncNotificationsUseCase,
  }) : _exportDataUseCase = exportDataUseCase,
       _importDataUseCase = importDataUseCase,
       _syncNotificationsUseCase = syncNotificationsUseCase,
       super(const SettingsState()) {
    on<SettingsExportRequested>(_onExportRequested);
    on<SettingsImportRequested>(_onImportRequested);
  }

  final ExportDataUseCase _exportDataUseCase;
  final ImportDataUseCase _importDataUseCase;
  final SyncNotificationsUseCase _syncNotificationsUseCase;

  Future<void> _onExportRequested(
    SettingsExportRequested event,
    Emitter<SettingsState> emit,
  ) async {
    debugPrint('SettingsBloc: _onExportRequested started');
    emit(
      state.copyWith(
        exportStatus: AsyncStatus.inProgress,
        importStatus: AsyncStatus.idle,
        errorMessage: null,
      ),
    );
    try {
      final jsonText = await _exportDataUseCase();
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${tempDir.path}/starnyx_backup_$timestamp.json');
      await file.writeAsString(jsonText);
      debugPrint('SettingsBloc: Export successful, saved to ${file.path}');
      emit(
        state.copyWith(
          exportStatus: AsyncStatus.success,
          errorMessage: null,
          exportedFilePath: file.path,
        ),
      );
    } catch (e) {
      debugPrint('SettingsBloc: Export failed with error: $e');
      emit(
        state.copyWith(
          exportStatus: AsyncStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onImportRequested(
    SettingsImportRequested event,
    Emitter<SettingsState> emit,
  ) async {
    debugPrint('SettingsBloc: _onImportRequested started');
    emit(
      state.copyWith(
        importStatus: AsyncStatus.inProgress,
        exportStatus: AsyncStatus.idle,
        errorMessage: null,
      ),
    );
    try {
      await _importDataUseCase(event.jsonPayload);
      await _syncNotificationsUseCase.rebuildAllFromLocalData();
      debugPrint('SettingsBloc: Import successful');
      emit(
        state.copyWith(importStatus: AsyncStatus.success, errorMessage: null),
      );
    } catch (e) {
      debugPrint('SettingsBloc: Import failed with error: $e');
      emit(
        state.copyWith(
          importStatus: AsyncStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}

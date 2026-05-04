import 'dart:io';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:starnyx/core/constants/enums.dart';
import 'package:starnyx/core/services/core_services.dart';
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
    AppLogService logger = const NoOpAppLogService(),
  }) : _exportDataUseCase = exportDataUseCase,
       _importDataUseCase = importDataUseCase,
       _syncNotificationsUseCase = syncNotificationsUseCase,
       _logger = logger,
       super(const SettingsState()) {
    on<SettingsExportRequested>(_onExportRequested);
    on<SettingsImportRequested>(_onImportRequested);
  }

  final ExportDataUseCase _exportDataUseCase;
  final ImportDataUseCase _importDataUseCase;
  final SyncNotificationsUseCase _syncNotificationsUseCase;
  final AppLogService _logger;

  Future<void> _onExportRequested(
    SettingsExportRequested event,
    Emitter<SettingsState> emit,
  ) async {
    _logger.debug('SettingsBloc', 'export begin');
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
      _logger.debug(
        'SettingsBloc',
        'export success path=${file.path} bytes=${jsonText.length}',
      );
      emit(
        state.copyWith(
          exportStatus: AsyncStatus.success,
          errorMessage: null,
          exportedFilePath: file.path,
        ),
      );
    } catch (error, stackTrace) {
      _logger.error(
        'SettingsBloc',
        'export failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          exportStatus: AsyncStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onImportRequested(
    SettingsImportRequested event,
    Emitter<SettingsState> emit,
  ) async {
    _logger.debug(
      'SettingsBloc',
      'import begin keys=${event.jsonPayload.keys.join(',')}',
    );
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
      _logger.debug('SettingsBloc', 'import success');
      emit(
        state.copyWith(importStatus: AsyncStatus.success, errorMessage: null),
      );
    } catch (error, stackTrace) {
      _logger.error(
        'SettingsBloc',
        'import failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          importStatus: AsyncStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}

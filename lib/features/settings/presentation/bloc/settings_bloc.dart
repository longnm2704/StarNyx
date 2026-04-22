import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    emit(
      state.copyWith(exportStatus: AsyncStatus.inProgress, errorMessage: null),
    );
    try {
      // Logic for sharing/saving the exported JSON will be handled in UI or a service
      await _exportDataUseCase();
      emit(
        state.copyWith(exportStatus: AsyncStatus.success, errorMessage: null),
      );
    } catch (e) {
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
    emit(
      state.copyWith(importStatus: AsyncStatus.inProgress, errorMessage: null),
    );
    try {
      await _importDataUseCase(event.jsonPayload);
      await _syncNotificationsUseCase.rebuildAllFromLocalData();
      emit(
        state.copyWith(importStatus: AsyncStatus.success, errorMessage: null),
      );
    } catch (e) {
      emit(
        state.copyWith(
          importStatus: AsyncStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}

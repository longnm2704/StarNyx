import 'dart:io';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:starnyx/core/constants/enums.dart';
import 'package:starnyx/core/services/core_services.dart';
import 'package:starnyx/core/utils/backup_file_codec.dart';
import 'package:starnyx/domain/usecases/export_data_use_case.dart';
import 'package:starnyx/domain/usecases/import_data_use_case.dart';
import 'package:starnyx/domain/usecases/load_active_starnyx_use_case.dart';
import 'package:starnyx/domain/usecases/load_starnyx_progress_stats_use_case.dart';
import 'package:starnyx/domain/usecases/load_starnyxs_use_case.dart';
import 'package:starnyx/domain/usecases/set_all_reminders_enabled_use_case.dart';
import 'package:starnyx/domain/usecases/sync_notifications_use_case.dart';

import 'settings_event.dart';
import 'settings_state.dart';

typedef TempDirectoryProvider = Future<Directory> Function();
typedef NowProvider = DateTime Function();

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    required ExportDataUseCase exportDataUseCase,
    required ImportDataUseCase importDataUseCase,
    required SyncNotificationsUseCase syncNotificationsUseCase,
    required LoadStarnyxsUseCase loadStarnyxsUseCase,
    required LoadActiveStarNyxUseCase loadActiveStarNyxUseCase,
    required LoadStarNyxProgressStatsUseCase loadStarNyxProgressStatsUseCase,
    required SetAllRemindersEnabledUseCase setAllRemindersEnabledUseCase,
    BackupFileCodec? backupFileCodec,
    TempDirectoryProvider? tempDirectoryProvider,
    NowProvider? nowProvider,
    AppLogService logger = const NoOpAppLogService(),
  }) : _exportDataUseCase = exportDataUseCase,
       _importDataUseCase = importDataUseCase,
       _syncNotificationsUseCase = syncNotificationsUseCase,
       _loadStarnyxsUseCase = loadStarnyxsUseCase,
       _loadActiveStarNyxUseCase = loadActiveStarNyxUseCase,
       _loadStarNyxProgressStatsUseCase = loadStarNyxProgressStatsUseCase,
       _setAllRemindersEnabledUseCase = setAllRemindersEnabledUseCase,
       _backupFileCodec = backupFileCodec ?? BackupFileCodec(),
       _tempDirectoryProvider = tempDirectoryProvider ?? getTemporaryDirectory,
       _nowProvider = nowProvider ?? DateTime.now,
       _logger = logger,
       super(const SettingsState()) {
    on<SettingsExportRequested>(_onExportRequested);
    on<SettingsImportRequested>(_onImportRequested);
    on<SettingsSummaryRequested>(_onSummaryRequested);
    on<SettingsRemindersToggled>(_onRemindersToggled);
  }

  final ExportDataUseCase _exportDataUseCase;
  final ImportDataUseCase _importDataUseCase;
  final SyncNotificationsUseCase _syncNotificationsUseCase;
  final LoadStarnyxsUseCase _loadStarnyxsUseCase;
  final LoadActiveStarNyxUseCase _loadActiveStarNyxUseCase;
  final LoadStarNyxProgressStatsUseCase _loadStarNyxProgressStatsUseCase;
  final SetAllRemindersEnabledUseCase _setAllRemindersEnabledUseCase;
  final BackupFileCodec _backupFileCodec;
  final TempDirectoryProvider _tempDirectoryProvider;
  final NowProvider _nowProvider;
  final AppLogService _logger;

  Future<void> _onSummaryRequested(
    SettingsSummaryRequested event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _emitSummary(emit);
    } catch (error, stackTrace) {
      // Summary is decorative; keep the last known values on failure.
      _logger.error(
        'SettingsBloc',
        'summary failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _onRemindersToggled(
    SettingsRemindersToggled event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _setAllRemindersEnabledUseCase(event.enabled);
      await _emitSummary(emit);
    } catch (error, stackTrace) {
      _logger.error(
        'SettingsBloc',
        'reminders toggle failed enabled=${event.enabled}',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _emitSummary(Emitter<SettingsState> emit) async {
    final now = _nowProvider();
    final starnyxs = await _loadStarnyxsUseCase();
    final active = await _loadActiveStarNyxUseCase(now: now);
    final streak = active == null
        ? 0
        : (await _loadStarNyxProgressStatsUseCase(
            starnyxId: active.id,
            year: now.year,
            today: now,
          )).currentStreak;
    emit(
      state.copyWith(
        starnyxs: starnyxs,
        activeHabitTitle: active?.title,
        currentStreak: streak,
      ),
    );
  }

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
      final backupText = await _backupFileCodec.encodeJson(
        jsonText,
        passphrase: event.passphrase,
      );
      final tempDir = await _tempDirectoryProvider();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(_nowProvider());
      final file = File(
        '${tempDir.path}/starnyx_backup_$timestamp.$backupFileExtension',
      );
      await file.writeAsString(backupText);
      _logger.debug(
        'SettingsBloc',
        'export success path=${file.path} bytes=${backupText.length}',
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
          errorMessage: _settingsErrorMessageFor(SettingsFailureArea.export),
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
          errorMessage: _settingsErrorMessageFor(SettingsFailureArea.import),
        ),
      );
    }
  }
}

enum SettingsFailureArea { export, import }

String _settingsErrorMessageFor(SettingsFailureArea area) {
  switch (area) {
    case SettingsFailureArea.export:
      return 'Backup could not be created. Please try again.';
    case SettingsFailureArea.import:
      return 'Backup could not be imported. Check the file and try again.';
  }
}

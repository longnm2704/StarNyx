import 'dart:convert';

import 'package:starnyx/core/services/app_log_service.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/entities/completion.dart';
import 'package:starnyx/domain/entities/app_settings.dart';
import 'package:starnyx/domain/entities/journal_entry.dart';
import 'package:starnyx/core/utils/json_validation_utils.dart';
import 'package:starnyx/domain/repositories/starnyx_repository.dart';
import 'package:starnyx/domain/repositories/completion_repository.dart';
import 'package:starnyx/domain/repositories/app_settings_repository.dart';
import 'package:starnyx/domain/repositories/journal_entry_repository.dart';

// Validates and imports a full backup payload into local repositories.
class ImportDataUseCase {
  const ImportDataUseCase(
    this._starnyxRepository,
    this._completionRepository,
    this._journalEntryRepository,
    this._appSettingsRepository, {
    AppLogService logger = const NoOpAppLogService(),
  }) : _logger = logger;

  final StarNyxRepository _starnyxRepository;
  final CompletionRepository _completionRepository;
  final JournalEntryRepository _journalEntryRepository;
  final AppSettingsRepository _appSettingsRepository;
  final AppLogService _logger;

  Future<void> callFromJsonText(String jsonText) async {
    _logger.debug('ImportDataUseCase', 'decode begin bytes=${jsonText.length}');
    final dynamic decoded;
    try {
      decoded = jsonDecode(jsonText);
    } on FormatException {
      throw const ImportDataException(<String>['Import JSON is malformed.']);
    }

    if (decoded is! Map) {
      throw const ImportDataException(<String>[
        'Import JSON root must be an object.',
      ]);
    }

    final json = decoded.map<String, dynamic>(
      (key, value) => MapEntry(key.toString(), value),
    );
    await call(json);
  }

  Future<void> call(Map<String, dynamic> json) async {
    _logger.debug(
      'ImportDataUseCase',
      'import begin keys=${json.keys.join(',')}',
    );
    final validation = JsonValidationUtils.validateImportJson(json);
    if (!validation.isValid) {
      _logger.debug(
        'ImportDataUseCase',
        'validation failed errors=${validation.errors.length}',
      );
      throw ImportDataException(validation.errors);
    }

    final starnyxs = (json['starnyxs'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(_starnyxFromJson)
        .toList(growable: false);
    final completions = (json['completions'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(_completionFromJson)
        .toList(growable: false);
    final journalEntries = (json['journalEntries'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(_journalEntryFromJson)
        .toList(growable: false);
    final appSettings = _appSettingsFromJson(
      json['appSettings'] as Map<String, dynamic>,
    );
    _logger.debug(
      'ImportDataUseCase',
      'parsed starnyxs=${starnyxs.length} completions=${completions.length} '
          'journals=${journalEntries.length}',
    );

    final snapshot = await _captureCurrentData();

    try {
      await _clearCurrentData();
      await _saveImportedData(
        starnyxs: starnyxs,
        completions: completions,
        journalEntries: journalEntries,
        appSettings: appSettings,
      );
      _logger.debug('ImportDataUseCase', 'import success');
    } catch (error) {
      _logger.error(
        'ImportDataUseCase',
        'import write failed; attempting rollback',
        error: error,
      );
      try {
        await _restoreFromSnapshot(snapshot);
      } catch (rollbackError) {
        _logger.error(
          'ImportDataUseCase',
          'rollback failed',
          error: rollbackError,
        );
        throw ImportDataException(<String>[
          'Import failed while writing local data.',
          'Rollback failed: $rollbackError',
        ]);
      }

      _logger.debug('ImportDataUseCase', 'rollback success');
      throw ImportDataException(<String>[
        'Import failed while writing local data. Previous data was restored.',
        '$error',
      ]);
    }
  }

  Future<_ImportSnapshot> _captureCurrentData() async {
    final starnyxs = await _starnyxRepository.getAllStarnyxs();
    final completions = <Completion>[];
    final journalEntries = <JournalEntry>[];

    for (final starnyx in starnyxs) {
      completions.addAll(
        await _completionRepository.getCompletionsForStarnyx(starnyx.id),
      );
      journalEntries.addAll(
        await _journalEntryRepository.getJournalEntriesForStarnyx(starnyx.id),
      );
    }

    _logger.debug(
      'ImportDataUseCase',
      'snapshot captured starnyxs=${starnyxs.length} '
          'completions=${completions.length} journals=${journalEntries.length}',
    );
    return _ImportSnapshot(
      starnyxs: starnyxs,
      completions: completions,
      journalEntries: journalEntries,
      appSettings: await _appSettingsRepository.getAppSettings(),
    );
  }

  Future<void> _clearCurrentData() async {
    final currentStarnyxs = await _starnyxRepository.getAllStarnyxs();
    _logger.debug(
      'ImportDataUseCase',
      'clear current data starnyxs=${currentStarnyxs.length}',
    );
    for (final starnyx in currentStarnyxs) {
      await _completionRepository.deleteCompletionsForStarnyx(starnyx.id);
      await _journalEntryRepository.deleteJournalEntriesForStarnyx(starnyx.id);
      await _starnyxRepository.deleteStarnyxById(starnyx.id);
    }
  }

  Future<void> _saveImportedData({
    required List<StarNyx> starnyxs,
    required List<Completion> completions,
    required List<JournalEntry> journalEntries,
    required AppSettings appSettings,
  }) async {
    for (final starnyx in starnyxs) {
      await _starnyxRepository.saveStarnyx(starnyx);
    }

    for (final completion in completions) {
      await _completionRepository.saveCompletion(completion);
    }

    for (final entry in journalEntries) {
      await _journalEntryRepository.saveJournalEntry(entry);
    }

    await _appSettingsRepository.saveAppSettings(appSettings);
  }

  Future<void> _restoreFromSnapshot(_ImportSnapshot snapshot) async {
    await _clearCurrentData();

    for (final starnyx in snapshot.starnyxs) {
      await _starnyxRepository.saveStarnyx(starnyx);
    }

    for (final completion in snapshot.completions) {
      await _completionRepository.saveCompletion(completion);
    }

    for (final entry in snapshot.journalEntries) {
      await _journalEntryRepository.saveJournalEntry(entry);
    }

    final appSettings = snapshot.appSettings;
    if (appSettings != null) {
      await _appSettingsRepository.saveAppSettings(appSettings);
    }
  }
}

// Import throws a typed error so UI can surface readable validation messages.
class ImportDataException implements Exception {
  const ImportDataException(this.errors);

  final List<String> errors;

  @override
  String toString() => 'ImportDataException(${errors.join(', ')})';
}

StarNyx _starnyxFromJson(Map<String, dynamic> json) {
  return StarNyx(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    color: json['color'] as String,
    startDate: DateTime.parse(json['startDate'] as String),
    reminderEnabled: json['reminderEnabled'] as bool,
    reminderTime: json['reminderTime'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}

Completion _completionFromJson(Map<String, dynamic> json) {
  return Completion(
    starnyxId: json['starnyxId'] as String,
    date: DateTime.parse(json['date'] as String),
    completed: json['completed'] as bool,
  );
}

JournalEntry _journalEntryFromJson(Map<String, dynamic> json) {
  final date = DateTime.parse(json['date'] as String);
  return JournalEntry(
    id: 0,
    starnyxId: json['starnyxId'] as String,
    date: date,
    content: json['content'] as String,
    createdAt: json.containsKey('createdAt')
        ? DateTime.parse(json['createdAt'] as String)
        : date,
  );
}

AppSettings _appSettingsFromJson(Map<String, dynamic> json) {
  return AppSettings(
    lastSelectedStarnyxId: json['lastSelectedStarnyxId'] as String?,
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}

class _ImportSnapshot {
  const _ImportSnapshot({
    required this.starnyxs,
    required this.completions,
    required this.journalEntries,
    required this.appSettings,
  });

  final List<StarNyx> starnyxs;
  final List<Completion> completions;
  final List<JournalEntry> journalEntries;
  final AppSettings? appSettings;
}

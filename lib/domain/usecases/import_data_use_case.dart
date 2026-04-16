import 'dart:convert';

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
    this._appSettingsRepository,
  );

  final StarNyxRepository _starnyxRepository;
  final CompletionRepository _completionRepository;
  final JournalEntryRepository _journalEntryRepository;
  final AppSettingsRepository _appSettingsRepository;

  Future<void> callFromJsonText(String jsonText) async {
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
    final validation = JsonValidationUtils.validateImportJson(json);
    if (!validation.isValid) {
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

    await _clearCurrentData();
    await _saveImportedData(
      starnyxs: starnyxs,
      completions: completions,
      journalEntries: journalEntries,
      appSettings: appSettings,
    );
  }

  Future<void> _clearCurrentData() async {
    final currentStarnyxs = await _starnyxRepository.getAllStarnyxs();
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

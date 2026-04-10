import 'package:starnyx/core/utils/date_utils.dart';
import 'package:starnyx/domain/entities/starnyx.dart';
import 'package:starnyx/domain/entities/completion.dart';
import 'package:starnyx/domain/entities/app_settings.dart';
import 'package:starnyx/domain/entities/journal_entry.dart';
import 'package:starnyx/domain/repositories/starnyx_repository.dart';
import 'package:starnyx/domain/repositories/completion_repository.dart';
import 'package:starnyx/domain/repositories/app_settings_repository.dart';
import 'package:starnyx/domain/repositories/journal_entry_repository.dart';

// Builds the stable JSON payload used by backup export.
class ExportDataUseCase {
  const ExportDataUseCase(
    this._starnyxRepository,
    this._completionRepository,
    this._journalEntryRepository,
    this._appSettingsRepository,
  );

  final StarNyxRepository _starnyxRepository;
  final CompletionRepository _completionRepository;
  final JournalEntryRepository _journalEntryRepository;
  final AppSettingsRepository _appSettingsRepository;

  Future<Map<String, dynamic>> call({DateTime? now}) async {
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

    final appSettings =
        await _appSettingsRepository.getAppSettings() ??
        AppSettings(
          lastSelectedStarnyxId: null,
          updatedAt: now ?? DateTime.now(),
        );

    return <String, dynamic>{
      'schemaVersion': 1,
      'starnyxs': starnyxs.map(_starnyxToJson).toList(growable: false),
      'completions': completions.map(_completionToJson).toList(growable: false),
      'journalEntries': journalEntries
          .map(_journalEntryToJson)
          .toList(growable: false),
      'appSettings': _appSettingsToJson(appSettings),
    };
  }
}

Map<String, dynamic> _starnyxToJson(StarNyx starnyx) {
  return <String, dynamic>{
    'id': starnyx.id,
    'title': starnyx.title,
    'description': starnyx.description,
    'color': starnyx.color,
    'startDate': _dateKey(starnyx.startDate),
    'reminderEnabled': starnyx.reminderEnabled,
    'reminderTime': starnyx.reminderTime,
    'createdAt': starnyx.createdAt.toIso8601String(),
    'updatedAt': starnyx.updatedAt.toIso8601String(),
  };
}

Map<String, dynamic> _completionToJson(Completion completion) {
  return <String, dynamic>{
    'starnyxId': completion.starnyxId,
    'date': _dateKey(completion.date),
    'completed': completion.completed,
  };
}

Map<String, dynamic> _journalEntryToJson(JournalEntry entry) {
  return <String, dynamic>{
    'starnyxId': entry.starnyxId,
    'date': _dateKey(entry.date),
    'content': entry.content,
  };
}

Map<String, dynamic> _appSettingsToJson(AppSettings settings) {
  return <String, dynamic>{
    'lastSelectedStarnyxId': settings.lastSelectedStarnyxId,
    'updatedAt': settings.updatedAt.toIso8601String(),
  };
}

String _dateKey(DateTime value) {
  final normalized = DateUtils.dateOnly(value);
  final year = normalized.year.toString().padLeft(4, '0');
  final month = normalized.month.toString().padLeft(2, '0');
  final day = normalized.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

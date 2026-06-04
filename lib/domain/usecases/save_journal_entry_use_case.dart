import 'package:starnyx/core/utils/date_utils.dart';
import 'package:starnyx/core/services/app_log_service.dart';
import 'package:starnyx/domain/entities/journal_entry.dart';
import 'package:starnyx/domain/repositories/journal_entry_repository.dart';

// Saves one journal entry for a StarNyx.
class SaveJournalEntryUseCase {
  const SaveJournalEntryUseCase(
    this._repository, {
    AppLogService logger = const NoOpAppLogService(),
  }) : _logger = logger;

  final JournalEntryRepository _repository;
  final AppLogService _logger;

  Future<JournalEntry> call({
    required String starnyxId,
    required DateTime date,
    required String content,
  }) async {
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) {
      throw const FormatException('Journal content is required.');
    }
    if (trimmedContent.length > 4000) {
      throw const FormatException(
        'Journal content must be 4000 characters or fewer.',
      );
    }

    final normalizedDate = DateUtils.dateOnly(date);
    _logger.debug(
      'SaveJournalEntryUseCase',
      'save begin starnyxId=$starnyxId date=$normalizedDate '
          'contentLength=${trimmedContent.length}',
    );

    final entry = JournalEntry(
      id: 0, // Assigned by database
      starnyxId: starnyxId,
      date: normalizedDate,
      content: trimmedContent,
      createdAt: DateTime.now(),
    );

    await _repository.saveJournalEntry(entry);
    _logger.debug(
      'SaveJournalEntryUseCase',
      'save success starnyxId=$starnyxId date=$normalizedDate',
    );
    return entry;
  }
}

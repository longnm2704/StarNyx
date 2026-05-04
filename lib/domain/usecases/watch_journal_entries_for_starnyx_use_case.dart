import 'package:starnyx/core/services/app_log_service.dart';
import 'package:starnyx/domain/entities/journal_entry.dart';
import 'package:starnyx/domain/repositories/journal_entry_repository.dart';

// Streams journal entries for one StarNyx.
class WatchJournalEntriesForStarnyxUseCase {
  const WatchJournalEntriesForStarnyxUseCase(
    this._repository, {
    AppLogService logger = const NoOpAppLogService(),
  }) : _logger = logger;

  final JournalEntryRepository _repository;
  final AppLogService _logger;

  Stream<List<JournalEntry>> call(String starnyxId) {
    _logger.debug(
      'WatchJournalEntriesForStarnyxUseCase',
      'watch begin starnyxId=$starnyxId',
    );
    return _repository.watchJournalEntriesForStarnyx(starnyxId);
  }
}

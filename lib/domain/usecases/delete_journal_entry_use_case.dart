import 'package:starnyx/core/services/app_log_service.dart';
import 'package:starnyx/domain/repositories/journal_entry_repository.dart';

// Deletes one journal entry by its unique ID.
class DeleteJournalEntryUseCase {
  const DeleteJournalEntryUseCase(
    this._repository, {
    AppLogService logger = const NoOpAppLogService(),
  }) : _logger = logger;

  final JournalEntryRepository _repository;
  final AppLogService _logger;

  Future<void> call({required int id}) async {
    _logger.debug('DeleteJournalEntryUseCase', 'delete begin id=$id');
    await _repository.deleteJournalEntryById(id);
    _logger.debug('DeleteJournalEntryUseCase', 'delete success id=$id');
  }
}

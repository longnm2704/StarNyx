import 'package:starnyx/core/utils/date_utils.dart';
import 'package:starnyx/domain/repositories/journal_entry_repository.dart';

// Deletes one journal entry for one date.
class DeleteJournalEntryUseCase {
  const DeleteJournalEntryUseCase(this._repository);

  final JournalEntryRepository _repository;

  Future<void> call({required String starnyxId, required DateTime date}) {
    return _repository.deleteJournalEntryByDate(
      starnyxId: starnyxId,
      date: DateUtils.dateOnly(date),
    );
  }
}

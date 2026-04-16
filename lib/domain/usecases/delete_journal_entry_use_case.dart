import 'package:starnyx/domain/repositories/journal_entry_repository.dart';

// Deletes one journal entry by its unique ID.
class DeleteJournalEntryUseCase {
  const DeleteJournalEntryUseCase(this._repository);

  final JournalEntryRepository _repository;

  Future<void> call({required int id}) {
    return _repository.deleteJournalEntryById(id);
  }
}

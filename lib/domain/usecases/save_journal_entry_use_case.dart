import 'package:starnyx/core/utils/date_utils.dart';
import 'package:starnyx/domain/entities/journal_entry.dart';
import 'package:starnyx/domain/usecases/use_case_validation.dart';
import 'package:starnyx/domain/repositories/journal_entry_repository.dart';

// Saves one daily journal entry for a StarNyx.
class SaveJournalEntryUseCase {
  const SaveJournalEntryUseCase(this._repository);

  final JournalEntryRepository _repository;

  Future<JournalEntry> call({
    required String starnyxId,
    required DateTime date,
    required String content,
  }) async {
    final normalizedDate = DateUtils.dateOnly(date);
    await UseCaseValidation.validateJournalEntryCreation(
      repository: _repository,
      starnyxId: starnyxId,
      date: normalizedDate,
    );
    final entry = JournalEntry(
      starnyxId: starnyxId,
      date: normalizedDate,
      content: content,
    );

    await _repository.saveJournalEntry(entry);
    return entry;
  }
}

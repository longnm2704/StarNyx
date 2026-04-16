import 'package:starnyx/domain/entities/journal_entry.dart';
import 'package:starnyx/domain/repositories/journal_entry_repository.dart';

// Streams journal entries for one StarNyx.
class WatchJournalEntriesForStarnyxUseCase {
  const WatchJournalEntriesForStarnyxUseCase(this._repository);

  final JournalEntryRepository _repository;

  Stream<List<JournalEntry>> call(String starnyxId) {
    return _repository.watchJournalEntriesForStarnyx(starnyxId);
  }
}

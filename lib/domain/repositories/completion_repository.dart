import 'package:starnyx/domain/entities/completion.dart';

// Contract for reading and writing daily completion records.
abstract interface class CompletionRepository {
  // Stats and history screens need all completions for one StarNyx.
  Future<List<Completion>> getCompletionsForStarnyx(String starnyxId);

  // Watchers keep streak and completion-rate UI in sync.
  Stream<List<Completion>> watchCompletionsForStarnyx(String starnyxId);

  // Toggle flows need to inspect one date without loading everything first.
  Future<Completion?> getCompletionByDate({
    required String starnyxId,
    required DateTime date,
  });

  // Save abstracts both create and overwrite behavior for one date.
  Future<void> saveCompletion(Completion completion);

  // Targeted delete is used when a completion is cleared or undone.
  Future<void> deleteCompletionByDate({
    required String starnyxId,
    required DateTime date,
  });

  // Bulk delete helps imports and StarNyx deletion clean up related data.
  Future<void> deleteCompletionsForStarnyx(String starnyxId);
}

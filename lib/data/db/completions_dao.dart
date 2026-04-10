part of 'app_database.dart';

// Data access helpers for daily completion records.
@DriftAccessor(tables: <Type>[Completions])
class CompletionsDao extends DatabaseAccessor<AppDatabase>
    with _$CompletionsDaoMixin {
  CompletionsDao(super.db);

  // Stats calculations expect completion dates in ascending order.
  Future<List<Completion>> getCompletionsForStarnyx(String starnyxId) {
    return (select(completions)
          ..where((table) => table.starnyxId.equals(starnyxId))
          ..orderBy([(table) => OrderingTerm.asc(table.date)]))
        .get();
  }

  // Watchers let the home screen refresh streaks and rates automatically.
  Stream<List<Completion>> watchCompletionsForStarnyx(String starnyxId) {
    return (select(completions)
          ..where((table) => table.starnyxId.equals(starnyxId))
          ..orderBy([(table) => OrderingTerm.asc(table.date)]))
        .watch();
  }

  // Toggle flows often need to inspect one completion record for one date.
  Future<Completion?> getCompletion({
    required String starnyxId,
    required String date,
  }) {
    return (select(completions)..where(
          (table) =>
              table.starnyxId.equals(starnyxId) & table.date.equals(date),
        ))
        .getSingleOrNull();
  }

  // Composite key upsert keeps one completion record per StarNyx per day.
  Future<void> upsertCompletion(CompletionsCompanion companion) {
    return into(completions).insertOnConflictUpdate(companion);
  }

  // Targeted deletes are used when undoing or editing a single date.
  Future<int> deleteCompletion({
    required String starnyxId,
    required String date,
  }) {
    return (delete(completions)..where(
          (table) =>
              table.starnyxId.equals(starnyxId) & table.date.equals(date),
        ))
        .go();
  }

  // Bulk cleanup is useful for import replacement and habit deletion flows.
  Future<int> deleteCompletionsForStarnyx(String starnyxId) {
    return (delete(
      completions,
    )..where((table) => table.starnyxId.equals(starnyxId))).go();
  }
}

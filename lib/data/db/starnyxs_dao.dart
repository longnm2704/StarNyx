part of 'app_database.dart';

// Data access helpers for StarNyx habit records.
@DriftAccessor(tables: <Type>[StarNyxs])
class StarnyxsDao extends DatabaseAccessor<AppDatabase>
    with _$StarnyxsDaoMixin {
  StarnyxsDao(super.db);

  // Home and picker flows follow explicit user-controlled order.
  Future<List<StarNyx>> getAllStarnyxs() {
    return (select(starNyxs)..orderBy([
          (table) => OrderingTerm.asc(table.displayOrder),
          (table) => OrderingTerm.desc(table.updatedAt),
          (table) => OrderingTerm.asc(table.id),
        ]))
        .get();
  }

  // Watchers keep the UI reactive when habits are created, edited, or removed.
  Stream<List<StarNyx>> watchAllStarnyxs() {
    return (select(starNyxs)..orderBy([
          (table) => OrderingTerm.asc(table.displayOrder),
          (table) => OrderingTerm.desc(table.updatedAt),
          (table) => OrderingTerm.asc(table.id),
        ]))
        .watch();
  }

  // Detail and edit flows look up a StarNyx by its stable string id.
  Future<StarNyx?> getStarnyxById(String id) {
    return (select(
      starNyxs,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
  }

  // Upsert keeps import and edit flows simple when ids are already known.
  Future<void> upsertStarnyx(StarNyxsCompanion companion) {
    return into(starNyxs).insertOnConflictUpdate(companion);
  }

  Future<void> updateDisplayOrder(List<String> orderedIds) {
    return batch((batch) {
      for (var index = 0; index < orderedIds.length; index += 1) {
        batch.update(
          starNyxs,
          StarNyxsCompanion(displayOrder: Value(index)),
          where: (table) => table.id.equals(orderedIds[index]),
        );
      }
    });
  }

  // Deleting the habit lets SQLite cascade related rows for completions and journal entries.
  Future<int> deleteStarnyxById(String id) {
    return (delete(starNyxs)..where((table) => table.id.equals(id))).go();
  }
}

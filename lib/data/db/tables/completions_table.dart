import 'package:drift/drift.dart';
import 'package:starnyx/data/db/tables/starnyxs_table.dart';

class Completions extends Table {
  @override
  String get tableName => 'completions';

  TextColumn get starnyxId =>
      text().references(StarNyxs, #id, onDelete: KeyAction.cascade)();

  // Stored as YYYY-MM-DD to keep completion records date-only.
  TextColumn get date => text().withLength(min: 10, max: 10)();

  BoolColumn get completed => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>>? get primaryKey => <Column<Object>>{starnyxId, date};
}

import 'package:drift/drift.dart';
import 'package:starnyx/data/db/tables/starnyxs_table.dart';

class JournalEntries extends Table {
  @override
  String get tableName => 'journal_entries';

  TextColumn get starnyxId =>
      text().references(StarNyxs, #id, onDelete: KeyAction.cascade)();

  // Stored as YYYY-MM-DD to enforce one journal entry per day.
  TextColumn get date => text().withLength(min: 10, max: 10)();

  TextColumn get content => text().withLength(min: 1, max: 4000)();

  @override
  Set<Column<Object>>? get primaryKey => <Column<Object>>{starnyxId, date};
}

import 'package:drift/drift.dart';
import 'package:starnyx/data/db/tables/starnyxs_table.dart';

// Daily journal notes stored per StarNyx with support for multiple entries.
class JournalEntries extends Table {
  @override
  String get tableName => 'journal_entries';

  IntColumn get id => integer().autoIncrement()();

  TextColumn get starnyxId =>
      text().references(StarNyxs, #id, onDelete: KeyAction.cascade)();

  // Stored as YYYY-MM-DD for fast date-based lookup and grouping.
  TextColumn get date => text().withLength(min: 10, max: 10)();

  TextColumn get content => text().withLength(min: 1, max: 4000)();

  // Exact timestamp to sort multiple entries correctly within the same day.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

import 'package:drift/drift.dart';
import 'package:starnyx/data/db/tables/starnyxs_table.dart';

class AppSettings extends Table {
  @override
  String get tableName => 'app_settings';

  IntColumn get id => integer().withDefault(const Constant(1))();

  TextColumn get lastSelectedStarnyxId => text().nullable().references(
    StarNyxs,
    #id,
    onDelete: KeyAction.setNull,
  )();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>>? get primaryKey => <Column<Object>>{id};
}

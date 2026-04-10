import 'package:drift/drift.dart';

// Main habit table that mirrors the import/export StarNyx payload.
class StarNyxs extends Table {
  @override
  String get tableName => 'starnyxs';

  TextColumn get id => text()();

  TextColumn get title => text().withLength(min: 1, max: 120)();

  TextColumn get description => text().nullable()();

  TextColumn get color => text().withLength(min: 1, max: 32)();

  // Stored as YYYY-MM-DD to match import/export and date-only business rules.
  TextColumn get startDate => text().withLength(min: 10, max: 10)();

  BoolColumn get reminderEnabled =>
      boolean().withDefault(const Constant(false))();

  // Stored as HH:mm when reminders are enabled.
  TextColumn get reminderTime => text().withLength(min: 5, max: 5).nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  // String ids are generated in app code so import/export can preserve them exactly.
  Set<Column<Object>>? get primaryKey => <Column<Object>>{id};
}

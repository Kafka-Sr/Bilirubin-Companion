import 'package:drift/drift.dart';

/// Drift table definition for registered babies.
class Babies extends Table {
  TextColumn get babyId => text()();
  TextColumn get hospitalId => text()();
  TextColumn get babyName => text().withLength(max: 100)();
  DateTimeColumn get babyDob => dateTime()();
  RealColumn get babyWeight => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isArchived =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {babyId};
}

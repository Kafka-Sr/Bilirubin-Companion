import 'package:drift/drift.dart';

/// Drift table definition for registered babies.
class Babies extends Table {
  IntColumn get babyId => integer().autoIncrement()();
  TextColumn get babyName => text().withLength(max: 100)();
  DateTimeColumn get babyDob => dateTime()();
  RealColumn get babyWeight => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isArchived =>
      boolean().withDefault(const Constant(false))();
}

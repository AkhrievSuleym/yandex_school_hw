part of '../database.dart';

@DataClassName('AccountDbModel')
class AccountTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get balance => text()();
  TextColumn get currency => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  IntColumn get serverId => integer().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

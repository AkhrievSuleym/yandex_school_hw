part of '../database.dart';

@DataClassName('TransactionDbModel')
class TransactionTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get accountId => integer()();
  IntColumn get categoryId => integer()();
  TextColumn get amount => text()();
  DateTimeColumn get transactionDate => dateTime()();
  TextColumn get comment => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

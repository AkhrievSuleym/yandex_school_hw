part of '../database.dart';

@DataClassName('OperationDbModel')
class OperationTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get operationId =>
      text()(); // UUID или уникальный идентификатор операции
  TextColumn get type =>
      text()(); // Тип операции: create_account, update_account, delete_account и т.д.
  TextColumn get entity =>
      text()(); // Тип сущности: account, transaction, category и т.д.
  IntColumn get entityLocalId =>
      integer().nullable()(); // Локальный id сущности
  IntColumn get entityServerId =>
      integer().nullable()(); // Серверный id сущности (если есть)
  TextColumn get data => text()(); // JSON с данными операции
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get status => text().withDefault(
    const Constant('pending'),
  )(); // pending, success, error
}

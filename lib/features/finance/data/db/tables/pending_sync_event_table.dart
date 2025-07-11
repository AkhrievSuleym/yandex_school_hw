part of '../database.dart';

@DataClassName('PendingSyncEventDbModel')
class PendingSyncEventTable extends Table {
  IntColumn get id =>
      integer().autoIncrement()(); // Уникальный ID события в очереди

  TextColumn get eventType => text()();

  // ID локальной сущности, к которой относится событие (например, accountId)
  IntColumn get localEntityId => integer()();

  // ID сущности на сервере, если он известен (nullable)
  IntColumn get serverEntityId => integer().nullable()();

  // Данные события в виде JSON-строки (например, AccountCreateModel.toJson() или AccountUpdateModel.toJson())
  TextColumn get payload => text()();

  // Время создания события в очереди
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // Количество попыток отправки
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  // Последняя ошибка (для отладки)
  TextColumn get lastError => text().nullable()();
}

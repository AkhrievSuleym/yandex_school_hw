import 'package:drift/drift.dart' hide Column;
import 'package:yandex_shmr_hw/features/finance/data/db/database.dart'; // Скрываем Column из drift, чтобы не конфликтовать с другими пакетами

class OperationLocalDatasource {
  final Database _database;

  OperationLocalDatasource(this._database);

  Future<void> insertOperation({
    required String operationId,
    required String type,
    required String entity,
    int? entityLocalId,
    String? entityServerId,
    required String data,
  }) async {
    await _database
        .into(_database.operationTable)
        .insert(
          OperationTableCompanion.insert(
            operationId: operationId,
            type: type,
            entity: entity,
            entityLocalId: Value(
              entityLocalId,
            ), // Используем Value для nullable полей
            entityServerId: (entityServerId != null)
                ? Value(int.parse(entityServerId))
                : Value(null),
            data: data,
            timestamp: Value(DateTime.now()),
            isSynced: Value(false), // Изначально не синхронизирована
          ),
        );
  }

  /// Получает все несинхронизированные операции из базы данных.
  Future<List<OperationDbModel>> getPendingOperations() async {
    return await (_database.select(_database.operationTable)
          ..where((tbl) => tbl.isSynced.equals(false))
          ..orderBy([
            (tbl) =>
                OrderingTerm(expression: tbl.timestamp, mode: OrderingMode.asc),
          ])) // Сортировка по времени для обработки в порядке создания
        .get();
  }

  /// Удаляет операцию по её ID после успешной синхронизации.
  Future<void> deleteOperation(String operationId) async {
    await (_database.delete(
      _database.operationTable,
    )..where((tbl) => tbl.operationId.equals(operationId))).go();
  }

  /// Удаляет все операции (например, при полной очистке данных).
  Future<void> clearAllOperations() async {
    await _database.delete(_database.operationTable).go();
  }
}

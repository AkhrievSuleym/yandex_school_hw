import 'package:drift/drift.dart';
import 'package:yandex_shmr_hw/features/finance/data/db/database.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_history_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/enums/currency.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/pending/pending_sync_event_model.dart';

class AccountLocalDatasource {
  final Database _database;

  AccountLocalDatasource(this._database);

  Future<void> insertAccount(
    AccountModel account, {
    int? serverId,
    bool isSynced = false,
  }) async {
    final companion = AccountTableCompanion(
      id: Value(account.id),
      name: Value(account.name),
      balance: Value(account.balance),
      currency: Value(account.currency.name),
      createdAt: Value(account.createdAt),
      updatedAt: Value(account.updatedAt),
      serverId: Value(serverId), // Новое поле
      isSynced: Value(isSynced), // Новое поле
    );
    await _database.accountTable.insertOne(companion);
  }

  Future<AccountModel?> getAccountById(int localId) async {
    final accountDbModel = await (_database.select(
      _database.accountTable,
    )..where((tbl) => tbl.id.equals(localId))).getSingleOrNull();
    if (accountDbModel == null) return null;

    return AccountModel(
      id: accountDbModel.id,
      userId: 0,
      name: accountDbModel.name,
      balance: accountDbModel.balance,
      currency: Currency.values.firstWhere(
        (e) => e.name == accountDbModel.currency,
      ),
      createdAt: accountDbModel.createdAt,
      updatedAt: accountDbModel.updatedAt,
    );
  }

  Future<bool> updateAccount(AccountModel account) async {
    final existingDbModel = await (_database.select(
      _database.accountTable,
    )..where((tbl) => tbl.id.equals(account.id))).getSingleOrNull();

    if (existingDbModel == null) {
      return false;
    }

    final companion = AccountTableCompanion(
      id: Value(account.id), // ID для обновления
      name: Value(account.name),
      balance: Value(account.balance),
      currency: Value(account.currency.name),
      createdAt: Value(account.createdAt),
      updatedAt: Value(DateTime.now()),
      serverId: Value(existingDbModel.serverId),
      isSynced: Value(existingDbModel.isSynced),
    );
    final result = await _database
        .update(_database.accountTable)
        .replace(companion);
    return result;
  }

  Future<List<AccountDbModel>> getPendingAccountDbModels() async {
    return await (_database.select(
      _database.accountTable,
    )..where((tbl) => tbl.isSynced.equals(false))).get();
  }

  Future<void> updateAccountServerId(int localId, int serverId) async {
    await (_database.update(_database.accountTable)
          ..where((tbl) => tbl.id.equals(localId)))
        .write(AccountTableCompanion(serverId: Value(serverId)));
  }

  Future<void> markAccountDbModelSynced(int localId) async {
    await (_database.update(_database.accountTable)
          ..where((tbl) => tbl.id.equals(localId)))
        .write(const AccountTableCompanion(isSynced: Value(true)));
  }

  Future<void> insertAccountHistory(
    AccountHistoryModel history, {
    int? accountServerId,
    bool isSynced = false,
  }) async {
    final companion = AccountHistoryTableCompanion(
      id: const Value.absent(),
      accountId: Value(history.accountId),
      accountServerId: Value(accountServerId),
      changeType: Value(history.changeType),
      previousState: Value(history.previousState),
      newState: Value(history.newState),
      changeTimestamp: Value(history.changeTimestamp),
      createdAt: Value(history.createdAt),
      isSynced: Value(isSynced),
    );
    await _database.insertAccountHistory(companion);
  }

  Future<List<AccountHistoryModel>> getAccountHistory(int accountId) async {
    final historyDbModels = await _database.getAccountHistoryForAccount(
      accountId,
    );
    return historyDbModels
        .map(
          (dbModel) => AccountHistoryModel(
            id: dbModel.id,
            accountId: dbModel.accountId,
            changeType: dbModel.changeType,
            previousState: dbModel.previousState,
            newState: dbModel.newState,
            changeTimestamp: dbModel.changeTimestamp,
            createdAt: dbModel.createdAt,
          ),
        )
        .toList();
  }

  Future<void> updateAccountHistoryServerId(
    int localAccountId,
    int newServerId,
  ) async {
    await (_database.update(
      _database.accountHistoryTable,
    )..where((tbl) => tbl.accountId.equals(localAccountId))).write(
      AccountHistoryTableCompanion(accountServerId: Value(newServerId)),
    );
  }

  /// Помечает записи истории как синхронизированные.
  Future<void> markAccountHistoryDbModelSynced(int localAccountId) async {
    await (_database.update(_database.accountHistoryTable)..where(
          (tbl) =>
              tbl.accountId.equals(localAccountId) & tbl.isSynced.equals(false),
        ))
        .write(const AccountHistoryTableCompanion(isSynced: Value(true)));
  }

  /// Получает все несинхронизированные записи истории.
  Future<List<AccountHistoryDbModel>> getPendingAccountHistoryDbModels() async {
    return await (_database.select(
      _database.accountHistoryTable,
    )..where((tbl) => tbl.isSynced.equals(false))).get();
  }

  Future<void> addPendingSyncEvent(PendingSyncEventModel event) async {
    final companion = PendingSyncEventTableCompanion(
      id: const Value.absent(), // Let autoIncrement handle this
      eventType: Value(event.eventType),
      localEntityId: Value(event.localEntityId),
      serverEntityId: Value(event.serverEntityId),
      payload: Value(event.payload ?? ''),
      createdAt: Value(event.createdAt),
      retryCount: Value(event.retryCount),
      lastError: Value(event.lastError),
    );
    await _database.insertPendingSyncEvent(companion);
  }

  /// Получает все события из очереди синхронизации, отсортированные по времени создания.
  Future<List<PendingSyncEventModel>> getPendingSyncEvents() async {
    final dbModels = await _database.getPendingSyncEvents();
    return dbModels
        .map(
          (dbModel) => PendingSyncEventModel(
            id: dbModel.id,
            eventType: dbModel.eventType,
            localEntityId: dbModel.localEntityId,
            serverEntityId: dbModel.serverEntityId,
            payload: dbModel.payload,
            createdAt: dbModel.createdAt,
            retryCount: dbModel.retryCount,
            lastError: dbModel.lastError,
          ),
        )
        .toList();
  }

  /// Удаляет событие из очереди синхронизации по ID.
  Future<void> deletePendingSyncEvent(int id) async {
    await _database.deletePendingSyncEvent(id);
  }

  /// Обновляет событие в очереди синхронизации (например, увеличивает retryCount).
  Future<void> updatePendingSyncEvent(PendingSyncEventModel event) async {
    final companion = PendingSyncEventTableCompanion(
      id: Value(event.id),
      eventType: Value(event.eventType),
      localEntityId: Value(event.localEntityId),
      serverEntityId: Value(event.serverEntityId),
      payload: Value(event.payload ?? ''),
      createdAt: Value(event.createdAt),
      retryCount: Value(event.retryCount),
      lastError: Value(event.lastError),
    );
    await _database.updatePendingSyncEvent(companion);
  }
}

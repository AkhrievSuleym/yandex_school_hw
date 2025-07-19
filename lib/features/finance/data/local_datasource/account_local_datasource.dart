import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:yandex_shmr_hw/features/finance/data/db/database.dart';
import 'package:yandex_shmr_hw/features/finance/data/mappers/account_mapper.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_create_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_response_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_update_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/enums/currency.dart';
import 'package:uuid/uuid.dart';

class AccountLocalDatasource {
  final Database _db;

  AccountLocalDatasource(this._db);

  Future<AccountModel> addAccount(AccountCreateModel account) async {
    final now = DateTime.now();
    final newDbAccount = await _db
        .into(_db.accountTable)
        .insertReturning(
          AccountTableCompanion.insert(
            name: account.name,
            balance: account.balance,
            currency: account.currency.name, // Сохраняем имя enum
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
            isSynced: Value(false), // Изначально не синхронизирован
          ),
        );
    return AccountModel(
      id: newDbAccount.id, // Локальный ID
      name: newDbAccount.name,
      balance: newDbAccount.balance,
      currency: Currency.values.byName(newDbAccount.currency),
      createdAt: newDbAccount.createdAt,
      updatedAt: newDbAccount.updatedAt,
      userId: 0,
    );
  }

  Future<AccountModel?> getAccountById(int id) async {
    final dbAccount = await (_db.select(
      _db.accountTable,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    if (dbAccount == null) return null;
    return AccountModel(
      id: dbAccount.serverId ?? dbAccount.id,
      name: dbAccount.name,
      balance: dbAccount.balance,
      currency: Currency.values.byName(dbAccount.currency),
      createdAt: dbAccount.createdAt,
      updatedAt: dbAccount.updatedAt,
      userId: 0,
    );
  }

  Future<AccountModel> updateAccount(
    int accountId,
    AccountUpdateModel account,
  ) async {
    final now = DateTime.now();
    final updatedRows =
        await (_db.update(
          _db.accountTable,
        )..where((tbl) => tbl.id.equals(accountId))).writeReturning(
          AccountTableCompanion(
            name: Value(account.name),
            balance: Value(account.balance),
            currency: Value(account.currency.name),
            updatedAt: Value(now),
            isSynced: Value(false), // Помечаем как не синхронизированный
          ),
        );
    if (updatedRows.isEmpty) {
      throw Exception('Account with ID $accountId not found for update.');
    }
    final updatedDbAccount = updatedRows.first;
    return AccountModel(
      id: updatedDbAccount.serverId ?? updatedDbAccount.id,
      name: updatedDbAccount.name,
      balance: updatedDbAccount.balance,
      currency: Currency.values.byName(updatedDbAccount.currency),
      createdAt: updatedDbAccount.createdAt,
      updatedAt: updatedDbAccount.updatedAt,
      userId: 0,
    );
  }

  Future<List<AccountModel>> getAllAccounts() async {
    final accounts = await _db.select(_db.accountTable).get();
    return accounts.map((dbModel) {
      // Маппинг из AccountDbModel в AccountModel
      return AccountModel(
        id:
            dbModel.serverId ??
            dbModel.id, // Используем serverId если есть, иначе локальный ID
        name: dbModel.name,
        balance: dbModel.balance,
        currency: Currency.values.byName(dbModel.currency),
        createdAt: dbModel.createdAt,
        updatedAt: dbModel.updatedAt,
        userId: 0,
      );
    }).toList();
  }

  Future<void> updateAccountServerId(int localId, String serverId) async {
    await (_db.update(
      _db.accountTable,
    )..where((tbl) => tbl.id.equals(localId))).write(
      AccountTableCompanion(
        serverId: Value(int.parse(serverId)),
        isSynced: Value(true), // Помечаем как синхронизированный
      ),
    );
  }

  Future<void> clearAndInsertAll(List<AccountModel> accounts) async {
    await _db.transaction(() async {
      await _db.delete(_db.accountTable).go(); // Очищаем все
      for (final account in accounts) {
        await _db
            .into(_db.accountTable)
            .insert(
              AccountTableCompanion.insert(
                serverId: Value(account.id),
                name: account.name,
                balance: account.balance,
                currency: account.currency.name,
                createdAt: Value(account.createdAt),
                updatedAt: Value(account.updatedAt),
                isSynced: Value(true),
              ),
            );
      }
    });
  }

  Future<void> updateAccountFromResponse(
    AccountResponseModel remoteAccount,
  ) async {
    // Находим соответствующий локальный аккаунт по serverId
    final existingLocalAccount = await (_db.select(
      _db.accountTable,
    )..where((tbl) => tbl.serverId.equals(remoteAccount.id))).getSingleOrNull();

    if (existingLocalAccount != null) {
      await (_db.update(
        _db.accountTable,
      )..where((tbl) => tbl.id.equals(existingLocalAccount.id))).write(
        AccountTableCompanion(
          name: Value(remoteAccount.name),
          balance: Value(remoteAccount.balance),
          currency: Value(remoteAccount.currency.name),
          updatedAt: Value(DateTime.now()),
          isSynced: Value(true), // Считаем, что эти данные синхронизированы
        ),
      );
    }
    await _db
        .into(_db.accountTable)
        .insert(
          AccountTableCompanion.insert(
            serverId: Value(remoteAccount.id),
            name: remoteAccount.name,
            balance: remoteAccount.balance,
            currency: remoteAccount.currency.name,
            createdAt: Value(remoteAccount.createdAt),
            updatedAt: Value(remoteAccount.updatedAt),
            isSynced: Value(true), // Считаем, что эти данные синхронизированы
          ),
        );
  }
}

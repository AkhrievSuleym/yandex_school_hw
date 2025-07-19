import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:yandex_shmr_hw/features/finance/data/db/database.dart';
import 'package:yandex_shmr_hw/features/finance/data/mappers/transaction_mapper.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_request_model.dart';
import 'package:uuid/uuid.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_response_model.dart';

class TransactionLocalDatasource {
  final Database _db;

  TransactionLocalDatasource(this._db);

  Future<TransactionModel> addTransaction(
    TransactionRequestModel transaction,
  ) async {
    final now = DateTime.now();
    final companion = TransactionTableCompanion.insert(
      accountId: transaction.accountId,
      categoryId: transaction.categoryId,
      amount: transaction.amount,
      transactionDate: transaction.transactionDate,
      comment: Value(transaction.comment),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
      isSynced: Value(false), // Изначально не синхронизирована
    );
    final newDbTransaction = await _db
        .into(_db.transactionTable)
        .insertReturning(companion);

    return TransactionModel(
      id: newDbTransaction.id, // Локальный ID
      accountId: newDbTransaction.accountId,
      categoryId: newDbTransaction.categoryId,
      amount: newDbTransaction.amount,
      transactionDate: newDbTransaction.transactionDate,
      comment: newDbTransaction.comment,
      createdAt: newDbTransaction.createdAt,
      updatedAt: newDbTransaction.updatedAt,
    );
  }

  Future<void> deleteTransaction(int transactionId) async {
    final stmt = _db.delete(_db.transactionTable)
      ..where((tbl) => tbl.id.equals(transactionId));
    await stmt.go();
  }

  Future<TransactionModel> updateTransaction(
    int transactionId,
    TransactionRequestModel transaction,
  ) async {
    final now = DateTime.now();
    final updatedRows =
        await (_db.update(
          _db.transactionTable,
        )..where((tbl) => tbl.id.equals(transactionId))).writeReturning(
          TransactionTableCompanion(
            accountId: Value(transaction.accountId),
            categoryId: Value(transaction.categoryId),
            amount: Value(transaction.amount),
            transactionDate: Value(transaction.transactionDate),
            comment: Value(transaction.comment),
            updatedAt: Value(now),
            isSynced: Value(false), // Помечаем как не синхронизированную
          ),
        );
    if (updatedRows.isEmpty) {
      throw Exception(
        'Transaction with ID $transactionId not found for update.',
      );
    }
    final updatedDbTransaction = updatedRows.first;
    return TransactionModel(
      id: updatedDbTransaction.id, // Локальный ID
      accountId: updatedDbTransaction.accountId,
      categoryId: updatedDbTransaction.categoryId,
      amount: updatedDbTransaction.amount,
      transactionDate: updatedDbTransaction.transactionDate,
      comment: updatedDbTransaction.comment,
      createdAt: updatedDbTransaction.createdAt,
      updatedAt: updatedDbTransaction.updatedAt,
    );
  }

  @override
  Future<TransactionResponseModel> getTransactionById(int transactionId) async {
    final query = _db.select(_db.transactionTable).join([
      innerJoin(
        _db.accountTable,
        _db.accountTable.id.equalsExp(_db.transactionTable.accountId),
      ),
      innerJoin(
        _db.categoryTable,
        _db.categoryTable.id.equalsExp(_db.transactionTable.categoryId),
      ),
    ])..where(_db.transactionTable.id.equals(transactionId));

    final result = await query.getSingle();
    return result.toResponseModel();
  }

  @override
  Future<List<TransactionResponseModel>> getAccountTransactions({
    required int accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // 1. Базовый запрос с JOIN'ами
    final query = _db.select(_db.transactionTable).join([
      innerJoin(
        _db.accountTable,
        _db.accountTable.id.equalsExp(_db.transactionTable.accountId),
      ),
      innerJoin(
        _db.categoryTable,
        _db.categoryTable.id.equalsExp(_db.transactionTable.categoryId),
      ),
    ]);

    // 2. Формируем условия фильтрации динамически
    Expression<bool> filter = _db.transactionTable.accountId.equals(accountId);

    if (startDate != null) {
      filter =
          filter &
          _db.transactionTable.transactionDate.isBiggerOrEqualValue(startDate);
    }
    if (endDate != null) {
      filter =
          filter &
          _db.transactionTable.transactionDate.isSmallerOrEqualValue(endDate);
    }
    query.where(filter);

    // 3. Добавляем сортировку по дате для удобного отображения
    query.orderBy([OrderingTerm.desc(_db.transactionTable.transactionDate)]);

    final results = await query.get();

    // 4. Маппим каждую строку результата в нашу Response модель
    return results.map((row) => row.toResponseModel()).toList();
  }

  Future<void> updateTransactionServerId(int localId, String serverId) async {
    await (_db.update(_db.transactionTable)
          ..where((tbl) => tbl.id.equals(localId))) // Ищем по локальному ID
        .write(
          TransactionTableCompanion(
            serverId: Value(int.parse(serverId)),
            isSynced: Value(true), // Помечаем как синхронизированную
          ),
        );
  }
}

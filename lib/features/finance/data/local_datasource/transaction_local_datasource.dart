import 'package:drift/drift.dart';
import 'package:yandex_shmr_hw/features/finance/data/db/database.dart';
import 'package:yandex_shmr_hw/main.dart';

class TransactionLocalDatasource {
  Future<void> saveTransaction({
    required TransactionDbModel transaction,
  }) async {
    await database.transactionTable.insertOne(
      transaction,
      mode: InsertMode.insertOrFail,
    );
  }

  Future<List<TransactionDbModel>> getAllTransactions() async {
    return await database.select(database.transactionTable).get();
  }

  Future<List<TransactionDbModel>> getTransactionsByType({
    required bool isIncome,
  }) async {
    final categories = database.categoryTable;
    final transactions = database.transactionTable;

    final result = await (transactions.select().join([
      innerJoin(categories, categories.id.equalsExp(transactions.id)),
    ])..where(categories.isIncome.isValue(isIncome))).get();

    return result.map<TransactionDbModel>((e) {
      final data = e.rawData;
      return TransactionDbModel(
        id: data.read('id'),
        accountId: data.read('accountId'),
        categoryId: data.read('categoryId'),
        amount: data.read('amount'),
        transactionDate: data.read('transactionDate'),
        createdAt: data.read('createdAt'),
        updatedAt: data.read('updatedAt'),
      );
    }).toList();
  }
}

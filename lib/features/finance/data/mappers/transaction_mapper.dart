import 'package:drift/drift.dart';
import 'package:yandex_shmr_hw/features/finance/data/db/database.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_brief_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/category/category_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/enums/currency.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_response_model.dart';
import 'package:yandex_shmr_hw/main.dart';

extension TransactionMapper on TransactionDbModel {
  TransactionModel toModel() {
    return TransactionModel(
      id: id,
      accountId: accountId,
      categoryId: categoryId,
      amount: amount,
      transactionDate: transactionDate,
      comment: comment,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension FullTransactionMapper on TypedResult {
  TransactionResponseModel toResponseModel() {
    final transaction = readTable(database.transactionTable);
    final account = readTable(database.accountTable);
    final category = readTable(database.categoryTable);

    return TransactionResponseModel(
      id: transaction.id,
      amount: transaction.amount,
      transactionDate: transaction.transactionDate,
      comment: transaction.comment,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
      account: AccountBriefModel(
        id: account.id,
        name: account.name,
        balance: account.balance,
        currency: Currency.values.byName(account.currency),
      ),
      category: CategoryModel(
        id: category.id,
        name: category.name,
        emoji: category.emoji,
        isIncome: category.isIncome,
      ),
    );
  }
}

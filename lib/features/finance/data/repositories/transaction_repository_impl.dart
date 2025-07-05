import 'package:fpdart/fpdart.dart';
import 'package:yandex_shmr_hw/core/error/failure.dart';
import 'package:yandex_shmr_hw/features/finance/data/mocks.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_brief_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/category/category_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/enums/currency.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_request_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_response_model.dart';
import 'package:yandex_shmr_hw/features/finance/domain/repository/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  // Мок транзакций
  final List<TransactionModel> _mockTransactions =
      TransactionsMockData.generateTransactions();

  // Мок счетов
  final _mockAccounts = [
    AccountBriefModel(
      id: 1,
      name: 'Основной счёт',
      balance: '10000.00',
      currency: Currency.rub,
    ),
    AccountBriefModel(
      id: 2,
      name: 'Запасной счёт',
      balance: '500.00',
      currency: Currency.rub,
    ),
  ];

  // Мок категорий
  final _mockCategories = CategoriesMockData.mockCategories
      .map((json) => CategoryModel.fromJson(json))
      .toList();

  @override
  Future<Either<Failure, TransactionModel>> addTransaction(
    TransactionRequestModel transaction,
  ) async {
    try {
      await Future.delayed(Duration(milliseconds: 500));
      if (!_mockAccounts.any(
        (account) => account.id == transaction.accountId,
      )) {
        return left(Failure('Account not found'));
      }

      if (!_mockCategories.any(
        (category) => category.id == transaction.categoryId,
      )) {
        return left(Failure('Category not found'));
      }

      final newTransaction = TransactionModel(
        id: _mockTransactions.length + 1,
        accountId: transaction.accountId,
        categoryId: transaction.categoryId,
        amount: transaction.amount,
        transactionDate: transaction.transactionDate,
        comment: transaction.comment,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _mockTransactions.add(newTransaction);
      return right(newTransaction);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(int transactionId) async {
    try {
      await Future.delayed(Duration(milliseconds: 500));
      final index = _mockTransactions.indexWhere(
        (transaction) => transaction.id == transactionId,
      );
      if (index == -1) {
        return left(Failure('Transaction not found'));
      }
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TransactionResponseModel>>>
  getAccountTransactions({
    required int accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      await Future.delayed(Duration(milliseconds: 500));
      if (_mockAccounts.all((account) => account.id != accountId)) {
        return left(Failure('Account not found'));
      }
      List<TransactionModel> transactions = _mockTransactions
          .where((transaction) => transaction.accountId == accountId)
          .toList();
      if (startDate != null) {
        transactions = transactions
            .where(
              (transaction) =>
                  transaction.transactionDate.isAfter(startDate) ||
                  transaction.transactionDate.isAtSameMomentAs(startDate),
            )
            .toList();
      }
      if (endDate != null) {
        transactions = transactions
            .where(
              (transaction) =>
                  transaction.transactionDate.isBefore(endDate) ||
                  transaction.transactionDate.isAtSameMomentAs(endDate),
            )
            .toList();
      }
      final response = transactions.map((transaction) {
        final account = _mockAccounts.firstWhere(
          (acc) => acc.id == transaction.accountId,
        );
        final category = _mockCategories.firstWhere(
          (cat) => cat.id == transaction.categoryId,
        );
        return TransactionResponseModel(
          id: transaction.id,
          account: account,
          category: category,
          amount: transaction.amount,
          transactionDate: transaction.transactionDate,
          comment: transaction.comment,
          createdAt: transaction.createdAt,
          updatedAt: transaction.updatedAt,
        );
      }).toList();
      return right(response);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TransactionResponseModel>> getTransactionById({
    required int transactionId,
  }) async {
    try {
      await Future.delayed(Duration(milliseconds: 500));
      final transaction = _mockTransactions.firstWhere(
        (t) => t.id == transactionId,
      );
      final account = _mockAccounts.firstWhere(
        (a) => a.id == transaction.accountId,
      );
      final category = _mockCategories.firstWhere(
        (c) => c.id == transaction.categoryId,
      );
      final response = TransactionResponseModel(
        id: transaction.id,
        account: account,
        category: category,
        amount: transaction.amount,
        transactionDate: transaction.transactionDate,
        comment: transaction.comment,
        createdAt: transaction.createdAt,
        updatedAt: transaction.updatedAt,
      );
      return right(response);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TransactionResponseModel>> updateTransaction(
    int transactionId,
    TransactionRequestModel transaction,
  ) async {
    try {
      await Future.delayed(Duration(milliseconds: 500));
      final index = _mockTransactions.indexWhere(
        (transaction) => transaction.id == transactionId,
      );
      if (index == -1) {
        return left(Failure('Transaction not found'));
      }
      if (!_mockAccounts.any(
        (account) => account.id == transaction.accountId,
      )) {
        return left(Failure('Account not found'));
      }
      if (!_mockCategories.any(
        (category) => category.id == transaction.categoryId,
      )) {
        return left(Failure('Category not found'));
      }
      final updatedTransaction = TransactionModel(
        id: transactionId,
        accountId: transaction.accountId,
        categoryId: transaction.categoryId,
        amount: transaction.amount,
        transactionDate: transaction.transactionDate,
        comment: transaction.comment,
        createdAt: _mockTransactions[index].createdAt,
        updatedAt: DateTime.now(),
      );
      _mockTransactions[index] = updatedTransaction;

      final account = _mockAccounts.firstWhere(
        (acc) => acc.id == transaction.accountId,
      );
      final category = _mockCategories.firstWhere(
        (cat) => cat.id == transaction.categoryId,
      );
      final response = TransactionResponseModel(
        id: updatedTransaction.id,
        account: account,
        category: category,
        amount: updatedTransaction.amount,
        transactionDate: updatedTransaction.transactionDate,
        comment: updatedTransaction.comment,
        createdAt: updatedTransaction.createdAt,
        updatedAt: updatedTransaction.updatedAt,
      );
      return right(response);
    } catch (e) {
      print("we are here4");
      return left(Failure(e.toString()));
    }
  }
}

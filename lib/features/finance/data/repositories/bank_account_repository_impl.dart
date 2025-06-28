import 'package:fpdart/fpdart.dart';
import 'package:yandex_shmr_hw/core/error/failure.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_create_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_history_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_history_response_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_response_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_state_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_update_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/enums/change_type.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/enums/currency.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/stat/stat_item.dart';
import 'package:yandex_shmr_hw/features/finance/domain/repository/bank_account_repository.dart';

class BankAccountRepositoryImpl implements BankAccountRepository {
  // Мок счетов: основной и запасной
  final List<AccountModel> _mockAccounts = [
    AccountModel(
      id: 1,
      userId: 1,
      name: 'Основной счёт',
      balance: '10000.00',
      currency: Currency.rub,
      createdAt: DateTime.parse('2025-04-12T13:37:37.576Z'),
      updatedAt: DateTime.parse('2025-05-12T13:37:37.576Z'),
    ),
  ];

  // Мок истории счёта
  final List<AccountHistoryModel> _mockHistory = [
    AccountHistoryModel(
      id: 1,
      accountId: 1,
      changeType: ChangeType.creation,
      previousState: AccountStateModel(
        id: 1,
        name: 'Основной счёт',
        balance: '1000.00',
        currency: Currency.rub,
      ),
      newState: AccountStateModel(
        id: 1,
        name: 'Основной счёт',
        balance: '10000.00',
        currency: Currency.rub,
      ),
      changeTimestamp: DateTime.parse('2025-05-12T13:37:37.576Z'),
      createdAt: DateTime.parse('2025-04-12T13:37:37.576Z'),
    ),
  ];

  // Мок статистики
  final _mockStats = [
    StatItem(
      categoryId: 1,
      categoryName: 'Зарплата',
      emoji: '💰',
      amount: '5000.00',
    ),
    StatItem(
      categoryId: 5,
      categoryName: 'Продукты',
      emoji: '🍎',
      amount: '1500.00',
    ),
  ];
  @override
  Future<Either<Failure, List<AccountModel>>> getAllBankAccounts() async {
    try {
      // Имитация задержки сети
      await Future.delayed(Duration(milliseconds: 500));
      return right(_mockAccounts);
    } catch (e) {
      return left(Failure('Error!'));
    }
  }

  @override
  Future<Either<Failure, AccountModel>> addBankAccount(
    AccountCreateModel requestNewAccount,
  ) async {
    try {
      // Имитация задержки сети
      await Future.delayed(Duration(milliseconds: 500));
      final newAccount = AccountModel(
        id: _mockAccounts.length + 1,
        userId: 1,
        name: requestNewAccount.name,
        balance: requestNewAccount.balance,
        currency: requestNewAccount.currency,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _mockAccounts.add(newAccount);
      _mockHistory.add(
        AccountHistoryModel(
          id: _mockHistory.length + 1,
          accountId: newAccount.id,
          changeType: ChangeType.creation,
          previousState: null,
          newState: AccountStateModel(
            id: newAccount.id,
            name: newAccount.name,
            balance: newAccount.balance,
            currency: newAccount.currency,
          ),
          changeTimestamp: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      );
      return right(newAccount);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AccountHistoryResponseModel>> getAccountHistory(
    int accountId,
  ) async {
    try {
      // Имитация задержки сети
      await Future.delayed(Duration(milliseconds: 500));
      if (!_mockAccounts.any((account) => account.id == accountId)) {
        return left(Failure('Account not found'));
      }
      final account = _mockAccounts.firstWhere((a) => a.id == accountId);
      final history = _mockHistory
          .where((h) => h.accountId == accountId)
          .toList();

      final accountHistoryReponse = AccountHistoryResponseModel(
        accountid: account.id,
        accountname: account.name,
        currency: account.currency,
        currentBalance: account.balance,
        history: history.isNotEmpty
            ? history
            : [
                AccountHistoryModel(
                  id: 1,
                  accountId: account.id,
                  changeType: ChangeType.creation,
                  previousState: null,
                  newState: AccountStateModel(
                    id: account.id,
                    name: account.name,
                    balance: account.balance,
                    currency: account.currency,
                  ),
                  changeTimestamp: account.createdAt,
                  createdAt: account.createdAt,
                ),
              ],
      );
      return right(accountHistoryReponse);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AccountResponseModel>> getBankAccountById(
    int id,
  ) async {
    try {
      // Имитация задержки сети
      await Future.delayed(Duration(milliseconds: 500));
      final account = _mockAccounts.firstWhere((account) => account.id == id);
      return right(
        AccountResponseModel(
          id: account.id,
          name: account.name,
          balance: account.balance,
          currency: account.currency,
          incomeStats: _mockStats[0], // Зарплата
          expenseStats: _mockStats[1], // Продукты
          createdAt: account.createdAt,
          updatedAt: account.updatedAt,
        ),
      );
    } catch (e) {
      return left(Failure('Account not found'));
    }
  }

  @override
  Future<Either<Failure, AccountModel>> updateBankAccount(
    int accountId,
    AccountUpdateModel requestUpdatedAccount,
  ) async {
    try {
      await Future.delayed(Duration(milliseconds: 500));
      final index = _mockAccounts.indexWhere(
        (account) => account.id == accountId,
      );
      if (index == -1) {
        return left(Failure('Account not found'));
      }

      final oldAccount = _mockAccounts[index];
      final updatedAccount = AccountModel(
        id: oldAccount.id,
        userId: oldAccount.userId,
        name: requestUpdatedAccount.name,
        balance: requestUpdatedAccount.balance,
        currency: requestUpdatedAccount.currency,
        createdAt: oldAccount.createdAt,
        updatedAt: DateTime.now(),
      );
      _mockAccounts[index] = updatedAccount;
      _mockHistory.add(
        AccountHistoryModel(
          id: _mockHistory.length + 1,
          accountId: accountId,
          changeType: ChangeType.modification,
          previousState: AccountStateModel(
            id: oldAccount.id,
            name: oldAccount.name,
            balance: oldAccount.balance,
            currency: oldAccount.currency,
          ),
          newState: AccountStateModel(
            id: updatedAccount.id,
            name: updatedAccount.name,
            balance: updatedAccount.balance,
            currency: updatedAccount.currency,
          ),
          changeTimestamp: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      );
      return right(updatedAccount);
    } catch (e) {
      return left(Failure("Error!"));
    }
  }
}

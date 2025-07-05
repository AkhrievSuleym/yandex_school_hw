import 'package:fpdart/fpdart.dart';
import 'package:yandex_shmr_hw/core/error/failure.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_create_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_history_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_history_response_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_response_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_state_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_update_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/balance_data_point.dart';
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

  final List<AccountHistoryModel> _mockHistory = [
    AccountHistoryModel(
      id: 1,
      accountId: 1,
      changeType: ChangeType.creation,
      previousState: null,
      newState: AccountStateModel(
        id: 1,
        name: 'Основной счёт',
        balance: '50000.00', // Начальный баланс
        currency: Currency.rub,
      ),
      changeTimestamp: DateTime.now().subtract(
        const Duration(days: 30),
      ), // 30 дней назад
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    AccountHistoryModel(
      id: 2,
      accountId: 1,
      changeType: ChangeType.modification,
      previousState: AccountStateModel(
        id: 1,
        name: 'Основной счёт',
        balance: '50000.00',
        currency: Currency.rub,
      ),
      newState: AccountStateModel(
        id: 1,
        name: 'Основной счёт',
        balance: '55000.00',
        currency: Currency.rub,
      ),
      changeTimestamp: DateTime.now().subtract(const Duration(days: 25)),
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
    ),
    AccountHistoryModel(
      id: 3,
      accountId: 1,
      changeType: ChangeType.modification,
      previousState: AccountStateModel(
        id: 1,
        name: 'Основной счёт',
        balance: '55000.00',
        currency: Currency.rub,
      ),
      newState: AccountStateModel(
        id: 1,
        name: 'Основной счёт',
        balance: '52000.00',
        currency: Currency.rub,
      ),
      changeTimestamp: DateTime.now().subtract(const Duration(days: 20)),
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    AccountHistoryModel(
      id: 4,
      accountId: 1,
      changeType: ChangeType.modification,
      previousState: AccountStateModel(
        id: 1,
        name: 'Основной счёт',
        balance: '52000.00',
        currency: Currency.rub,
      ),
      newState: AccountStateModel(
        id: 1,
        name: 'Основной счёт',
        balance: '70000.00',
        currency: Currency.rub,
      ),
      changeTimestamp: DateTime.now().subtract(const Duration(days: 15)),
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    AccountHistoryModel(
      id: 5,
      accountId: 1,
      changeType: ChangeType.modification,
      previousState: AccountStateModel(
        id: 1,
        name: 'Основной счёт',
        balance: '70000.00',
        currency: Currency.rub,
      ),
      newState: AccountStateModel(
        id: 1,
        name: 'Основной счёт',
        balance: '-5000.00',
        currency: Currency.rub,
      ),
      changeTimestamp: DateTime.now().subtract(const Duration(days: 10)),
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    AccountHistoryModel(
      id: 6,
      accountId: 1,
      changeType: ChangeType.modification,
      previousState: AccountStateModel(
        id: 1,
        name: 'Основной счёт',
        balance: '-5000.00',
        currency: Currency.rub,
      ),
      newState: AccountStateModel(
        id: 1,
        name: 'Основной счёт',
        balance: '2000.00',
        currency: Currency.rub,
      ),
      changeTimestamp: DateTime.now().subtract(const Duration(days: 5)),
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    AccountHistoryModel(
      id: 7,
      accountId: 1,
      changeType: ChangeType.modification,
      previousState: AccountStateModel(
        id: 1,
        name: 'Основной счёт',
        balance: '2000.00',
        currency: Currency.rub,
      ),
      newState: AccountStateModel(
        id: 1,
        name: 'Основной счёт',
        balance: '10000.00',
        currency: Currency.rub,
      ),
      changeTimestamp: DateTime.now().subtract(
        const Duration(days: 0),
      ), // Сегодня
      createdAt: DateTime.now().subtract(const Duration(days: 0)),
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

  @override
  Future<Either<Failure, List<BalanceDataPoint>>> getBalanceHistoryForChart(
    int accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      await Future.delayed(
        const Duration(milliseconds: 700),
      ); // Имитация задержки

      final account = _mockAccounts.firstWhere((acc) => acc.id == accountId);
      final initialBalance = double.parse(account.balance);

      // Получаем все истории для данного счета
      final allHistory =
          _mockHistory.where((h) => h.accountId == accountId).toList()
            ..sort((a, b) => a.changeTimestamp.compareTo(b.changeTimestamp));

      // Если нет истории, просто возвращаем текущий баланс на все дни в диапазоне
      if (allHistory.isEmpty) {
        final List<BalanceDataPoint> dailyBalances = [];
        for (
          DateTime date = startDate;
          date.isBefore(endDate.add(Duration(days: 1)));
          date = date.add(const Duration(days: 1))
        ) {
          dailyBalances.add(
            BalanceDataPoint(date: date, amount: initialBalance),
          );
        }
        return right(dailyBalances);
      }

      // Находим начальный баланс до startDate
      double currentBalance = 0.0;
      final firstHistoryEntry = allHistory.firstWhere(
        (h) => h.changeType == ChangeType.creation,
        orElse: () => allHistory.first, // Если нет creation, берем самую старую
      );
      currentBalance = double.parse(firstHistoryEntry.newState.balance);

      // Если есть изменения до startDate, корректируем начальный баланс
      for (final history in allHistory) {
        if (history.changeTimestamp.isBefore(startDate)) {
          if (history.changeType == ChangeType.creation) {
            currentBalance = double.parse(history.newState.balance);
          } else if (history.changeType == ChangeType.modification) {
            currentBalance = double.parse(history.newState.balance);
          }
          // Для транзакций нужно получать сумму транзакции и применять
          // Для упрощения, пока только изменение баланса счета напрямую из history.
        }
      }

      final Map<DateTime, double> dailyBalancesMap = {};
      DateTime currentDate = startDate;

      while (currentDate.isBefore(endDate.add(const Duration(days: 1)))) {
        // Проверяем, есть ли истории изменений в этот день
        final dayHistory =
            allHistory
                .where(
                  (h) =>
                      h.changeTimestamp.year == currentDate.year &&
                      h.changeTimestamp.month == currentDate.month &&
                      h.changeTimestamp.day == currentDate.day,
                )
                .toList()
              ..sort((a, b) => a.changeTimestamp.compareTo(b.changeTimestamp));

        if (dayHistory.isNotEmpty) {
          // Если есть изменения в этот день, берем баланс после последнего изменения за этот день
          currentBalance = double.parse(dayHistory.last.newState.balance);
        } else {
          // Если нет изменений в этот день, баланс остается как в предыдущий день
          // (уже хранится в currentBalance)
        }

        dailyBalancesMap[currentDate] = currentBalance;
        currentDate = currentDate.add(const Duration(days: 1));
      }

      final List<BalanceDataPoint> result =
          dailyBalancesMap.entries
              .map((e) => BalanceDataPoint(date: e.key, amount: e.value))
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));

      return right(result);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}

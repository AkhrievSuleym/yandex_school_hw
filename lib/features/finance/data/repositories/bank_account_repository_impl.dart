import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'dart:convert';
import 'package:yandex_shmr_hw/core/error/failure.dart';
import 'package:yandex_shmr_hw/core/network/connectivity_service.dart';
import 'package:yandex_shmr_hw/core/utils/extensions.dart';
import 'package:yandex_shmr_hw/features/finance/data/local_datasource/account_local_datasource.dart';
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
import 'package:yandex_shmr_hw/features/finance/data/models/pending/pending_sync_event_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/stat/stat_item.dart';
import 'package:yandex_shmr_hw/features/finance/data/remote_datasource/account_remote_ds.dart';
import 'package:yandex_shmr_hw/features/finance/domain/repository/bank_account_repository.dart';

class BankAccountRepositoryImpl implements BankAccountRepository {
  final AccountLocalDatasource _localDatasource;
  final AccountRemoteDatasource _remoteDatasource;
  final ConnectivityService _connectivityService;

  BankAccountRepositoryImpl(
    this._localDatasource,
    this._remoteDatasource,
    this._connectivityService,
  );

  // Вспомогательная функция для генерации локального ID
  int _generateLocalId() {
    return DateTime.now().microsecondsSinceEpoch;
  }

  Future<void> _addSyncEvent(
    String eventType,
    int localEntityId, {
    int? serverEntityId,
    Map<String, dynamic>? payload,
  }) async {
    final String? encodedPayload = payload != null ? jsonEncode(payload) : null;
    final event = PendingSyncEventModel(
      id: _generateLocalId(),
      eventType: eventType,
      localEntityId: localEntityId,
      serverEntityId: serverEntityId,
      payload: encodedPayload,
      createdAt: DateTime.now(),
      retryCount: 0,
      lastError: null,
    );
    await _localDatasource.addPendingSyncEvent(event);
  }

  Failure _mapLocalExceptionToFailure(Object e) {
    return Failure('Ошибка локального хранилища: ${e.toString()}');
  }

  Failure _mapDioExceptionToFailure(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.unknown) {
      return Failure('Нет подключения к интернету или таймаут.');
    } else if (e.type == DioExceptionType.badResponse) {
      if (e.response?.statusCode == 404) {
        return Failure('Ресурс не найден. Ошибка: ${e.response?.statusCode}');
      } else if (e.response?.statusCode == 401 ||
          e.response?.statusCode == 403) {
        return Failure('Недостаточно прав. Ошибка: ${e.response?.statusCode}');
      }
      return Failure(
        'Ошибка сервера: ${e.response?.statusCode} - ${e.response?.data}',
      );
    }
    return Failure('Неизвестная ошибка сети: ${e.message}');
  }

  // @override
  // Future<Either<Failure, List<AccountModel>>> getAllBankAccounts() async {
  //   try {
  //     final localAccounts = await _localDatasource.getAllAccounts();
  //     if (localAccounts.isNotEmpty) {
  //       return right(localAccounts);
  //     }

  //     if (await _connectivityService.isConnected()) {
  //       try {

  //         final remoteAccounts = await _remoteDatasource.getAllAccounts();
  //         for (var account in remoteAccounts) {
  //           await _localDatasource.insertAccount(
  //             account,
  //             serverId: account.id, // Используем id как serverId
  //             isSynced: true,
  //           );
  //         }
  //         return right(remoteAccounts);
  //       } on DioException catch (e) {
  //         return left(_mapDioExceptionToFailure(e));
  //       } catch (e) {
  //         return left(Failure('Неизвестная ошибка при получении счетов с сервера: ${e.toString()}'));
  //       }
  //     } else {
  //       return left(Failure('Нет подключения к интернету и нет кэшированных данных.'));
  //     }
  //   } catch (e) {
  //     return left(_mapLocalExceptionToFailure(e));
  //   }
  // }

  @override
  Future<Either<Failure, AccountModel>> addBankAccount(
    AccountCreateModel requestNewAccount,
  ) async {
    try {
      final localId = _generateLocalId();

      final newAccount = AccountModel(
        id: localId,
        userId: 0,
        name: requestNewAccount.name,
        balance: requestNewAccount.balance,
        currency: requestNewAccount.currency,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _localDatasource.insertAccount(newAccount, isSynced: false);

      await _addSyncEvent(
        'createAccount',
        localId,
        payload: requestNewAccount.toJson(),
      );

      // 5. Попытка синхронизировать немедленно, если есть интернет
      if (await _connectivityService.isConnected()) {
        try {
          final remoteResponse = await _remoteDatasource.createAccount(
            requestNewAccount,
          );

          await _localDatasource.updateAccountServerId(
            localId,
            remoteResponse.id,
          );
          await _localDatasource.markAccountDbModelSynced(localId);

          final pendingEvents = await _localDatasource.getPendingSyncEvents();
          final eventToDelete = pendingEvents.firstWhereOrNull(
            (event) =>
                event.eventType == 'createAccount' &&
                event.localEntityId == localId,
          );
          if (eventToDelete != null) {
            await _localDatasource.deletePendingSyncEvent(eventToDelete.id);
          }

          return right(remoteResponse);
        } on DioException catch (e) {
          return left(_mapDioExceptionToFailure(e));
        } on Exception catch (e) {
          return left(
            Failure(
              'Неизвестная ошибка при создании счета на сервере: ${e.toString()}',
            ),
          );
        }
      }

      return right(newAccount);
    } catch (e) {
      return left(_mapLocalExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, AccountHistoryResponseModel>> getAccountHistory(
    int accountId,
  ) async {
    try {
      // 1. Попытка получить историю из локальной БД
      final history = await _localDatasource.getAccountHistory(accountId);
      final account = await _localDatasource.getAccountById(accountId);

      // Если есть локальный аккаунт и история для него
      if (account != null && history.isNotEmpty) {
        return right(
          AccountHistoryResponseModel(
            accountid: account.id,
            accountname: account.name,
            currency: account.currency,
            currentBalance: account.balance,
            history: history,
          ),
        );
      }

      // 2. Если локальных данных нет, пытаемся получить с сервера
      if (await _connectivityService.isConnected()) {
        try {
          // remoteDatasource.getAccountHistory ожидает String id
          final remoteHistoryResponse = await _remoteDatasource
              .getAccountHistory(accountId.toString());

          final accountDbModel = await _localDatasource.getAccountById(
            accountId,
          );

          for (var historyItem in remoteHistoryResponse.history) {
            await _localDatasource.insertAccountHistory(
              historyItem,
              accountServerId: 0,
              isSynced: true,
            );
          }
          return right(remoteHistoryResponse);
        } on DioException catch (e) {
          return left(_mapDioExceptionToFailure(e));
        } on Exception catch (e) {
          return left(
            Failure(
              'Неизвестная ошибка при получении истории с сервера: ${e.toString()}',
            ),
          );
        }
      } else {
        return left(
          Failure(
            'Нет подключения к интернету и нет кэшированной истории для данного счета.',
          ),
        );
      }
    } catch (e) {
      return left(_mapLocalExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, AccountResponseModel>> getBankAccountById(
    int id,
  ) async {
    try {
      final localAccount = await _localDatasource.getAccountById(id);
      if (localAccount != null) {
        return right(
          AccountResponseModel(
            id: localAccount.id,
            name: localAccount.name,
            balance: localAccount.balance,
            currency: localAccount.currency,
            createdAt: localAccount.createdAt,
            updatedAt: localAccount.updatedAt,
            incomeStats:
                const [], // TODO: Реализовать получение реальной статистики
            expenseStats:
                const [], // TODO: Реализовать получение реальной статистики
          ),
        );
      }

      if (await _connectivityService.isConnected()) {
        try {
          final remoteAccountResponse = await _remoteDatasource.getAccountById(
            id.toString(),
          );
          await _localDatasource.insertAccount(
            AccountModel(
              id: remoteAccountResponse.id,
              userId: 0,
              name: remoteAccountResponse.name,
              balance: remoteAccountResponse.balance,
              currency: remoteAccountResponse.currency,
              createdAt: remoteAccountResponse.createdAt,
              updatedAt: remoteAccountResponse.updatedAt,
            ),
            serverId: remoteAccountResponse.id,
            isSynced: true,
          );
          return right(remoteAccountResponse);
        } on DioException catch (e) {
          return left(_mapDioExceptionToFailure(e));
        } on Exception catch (e) {
          return left(
            Failure(
              'Неизвестная ошибка при получении счета с сервера: ${e.toString()}',
            ),
          );
        }
      } else {
        return left(
          Failure(
            'Нет подключения к интернету и нет кэшированных данных для этого счета.',
          ),
        );
      }
    } catch (e) {
      return left(_mapLocalExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, AccountModel>> updateBankAccount(
    int accountId,
    AccountUpdateModel requestUpdatedAccount,
  ) async {
    try {
      final existingAccount = await _localDatasource.getAccountById(accountId);
      if (existingAccount == null) {
        return left(Failure('Счет с ID $accountId не найден в локальной БД.'));
      }

      final updatedLocalAccount = AccountModel(
        id: existingAccount.id,
        userId: existingAccount.userId,
        name: requestUpdatedAccount.name,
        balance: requestUpdatedAccount.balance,
        currency: requestUpdatedAccount.currency,
        createdAt: existingAccount.createdAt,
        updatedAt: DateTime.now(),
      );

      final success = await _localDatasource.updateAccount(updatedLocalAccount);
      if (!success) {
        return left(Failure('Не удалось обновить счет в локальной БД.'));
      }

      await _addSyncEvent(
        'updateAccount',
        accountId,
        payload: requestUpdatedAccount.toJson(),
      );

      if (await _connectivityService.isConnected()) {
        try {
          final remoteId = (accountId).toString();
          final remoteResponse = await _remoteDatasource.updateAccount(
            remoteId,
            requestUpdatedAccount,
          );
          await _localDatasource.markAccountDbModelSynced(accountId);

          final pendingEvents = await _localDatasource.getPendingSyncEvents();
          final eventToDelete = pendingEvents.firstWhereOrNull(
            (event) =>
                event.eventType == 'updateAccount' &&
                event.localEntityId == accountId,
          );
          if (eventToDelete != null) {
            await _localDatasource.deletePendingSyncEvent(eventToDelete.id);
          }
          return right(remoteResponse);
        } on DioException catch (e) {
          return left(_mapDioExceptionToFailure(e));
        } on Exception catch (e) {
          return left(
            Failure(
              'Неизвестная ошибка при обновлении счета на сервере: ${e.toString()}',
            ),
          );
        }
      }
      return right(updatedLocalAccount);
    } catch (e) {
      return left(_mapLocalExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<BalanceDataPoint>>> getBalanceHistoryForChart(
    int accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Получаем полную историю из локальной БД
      List<AccountHistoryModel> allHistory = await _localDatasource
          .getAccountHistory(accountId);

      // Если история пуста, попробуем загрузить с сервера
      if (allHistory.isEmpty && await _connectivityService.isConnected()) {
        try {
          final remoteHistoryResponse = await _remoteDatasource
              .getAccountHistory(accountId.toString());
          // Сохраняем полученную историю локально
          final accountDbModel = await _localDatasource.getAccountById(
            accountId,
          );
          final accountServerId = 0;

          for (var historyItem in remoteHistoryResponse.history) {
            await _localDatasource.insertAccountHistory(
              historyItem,
              accountServerId: accountServerId,
              isSynced: true,
            );
          }
          // Обновляем allHistory из локальной БД после сохранения, чтобы использовать свежие данные
          allHistory = await _localDatasource.getAccountHistory(
            accountId,
          ); // Перезагружаем после вставки
        } on DioException catch (e) {
          // Если не удалось загрузить с сервера, продолжаем с тем, что есть локально (возможно, ничего)
          return left(_mapDioExceptionToFailure(e));
        } on Exception catch (e) {
          return left(
            Failure(
              'Неизвестная ошибка при загрузке истории баланса с сервера: ${e.toString()}',
            ),
          );
        }
      }

      final account = await _localDatasource.getAccountById(accountId);
      if (account == null) {
        return left(Failure('Счет не найден для получения истории баланса.'));
      }

      // Парсим начальный баланс
      final initialBalance = double.tryParse(account.balance) ?? 0.0;

      final filteredAndSortedHistory =
          allHistory.where((h) => h.accountId == accountId).toList()
            ..sort((a, b) => a.changeTimestamp.compareTo(b.changeTimestamp));

      // Если история все еще пуста после всех попыток, возвращаем текущий баланс на все дни
      if (filteredAndSortedHistory.isEmpty) {
        final List<BalanceDataPoint> dailyBalances = [];
        // Нормализуем даты до начала дня
        DateTime currentDay = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
        );
        final endDay = DateTime(endDate.year, endDate.month, endDate.day);

        while (currentDay.isBefore(endDay.add(const Duration(days: 1)))) {
          dailyBalances.add(
            BalanceDataPoint(date: currentDay, amount: initialBalance),
          );
          currentDay = currentDay.add(const Duration(days: 1));
        }
        return right(dailyBalances);
      }

      // Вычисляем баланс на каждый день в заданном диапазоне
      double currentBalance =
          initialBalance; // Начинаем с текущего баланса счета
      final Map<DateTime, double> dailyBalancesMap = {};

      // Определяем баланс на начало startDate
      // Ищем последнее изменение до или в startDate
      for (final historyEntry in filteredAndSortedHistory) {
        // Нормализуем changeTimestamp до начала дня для сравнения
        final historyDay = DateTime(
          historyEntry.changeTimestamp.year,
          historyEntry.changeTimestamp.month,
          historyEntry.changeTimestamp.day,
        );

        if (historyDay.isBefore(
              DateTime(startDate.year, startDate.month, startDate.day),
            ) ||
            historyDay.isAtSameMomentAs(
              DateTime(startDate.year, startDate.month, startDate.day),
            )) {
          currentBalance =
              double.tryParse(historyEntry.newState.balance) ?? currentBalance;
        } else {
          break; // История отсортирована, дальше изменения после startDate
        }
      }

      DateTime currentDate = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );
      final finalEndDateInclusive = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
      );

      while (currentDate.isBefore(
        finalEndDateInclusive.add(const Duration(days: 1)),
      )) {
        // Находим все изменения за текущий день
        final dayHistory =
            filteredAndSortedHistory
                .where(
                  (h) =>
                      h.changeTimestamp.year == currentDate.year &&
                      h.changeTimestamp.month == currentDate.month &&
                      h.changeTimestamp.day == currentDate.day,
                )
                .toList()
              ..sort(
                (a, b) => a.changeTimestamp.compareTo(b.changeTimestamp),
              ); // Дополнительная сортировка по времени для дня

        if (dayHistory.isNotEmpty) {
          // Если есть изменения в этот день, берем баланс после последнего изменения за этот день
          currentBalance =
              double.tryParse(dayHistory.last.newState.balance) ??
              currentBalance;
        }
        // Если нет изменений в этот день, баланс остается как в предыдущий день (он уже хранится в currentBalance)

        dailyBalancesMap[currentDate] = currentBalance;
        currentDate = currentDate.add(const Duration(days: 1));
      }

      // Преобразуем Map в List<BalanceDataPoint> и сортируем по дате
      final List<BalanceDataPoint> result =
          dailyBalancesMap.entries
              .map((e) => BalanceDataPoint(date: e.key, amount: e.value))
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));

      return right(result);
    } catch (e) {
      return left(_mapLocalExceptionToFailure(e));
    }
  }

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
  Future<Either<Failure, List<AccountModel>>> getAllBankAccounts() {
    // TODO: implement getAllBankAccounts
    throw UnimplementedError();
  }
}

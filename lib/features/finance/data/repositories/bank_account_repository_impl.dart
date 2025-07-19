import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:yandex_shmr_hw/core/error/failure.dart';
import 'package:yandex_shmr_hw/core/network/connectivity_service.dart';
import 'package:yandex_shmr_hw/core/sync/sync_service.dart';
import 'package:yandex_shmr_hw/features/finance/data/local_datasource/account_local_datasource.dart';
import 'package:yandex_shmr_hw/features/finance/data/local_datasource/operation_local_datasource.dart';
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
import 'package:yandex_shmr_hw/features/finance/data/remote_datasource/account_remote_ds.dart';
import 'package:yandex_shmr_hw/features/finance/domain/repository/bank_account_repository.dart';

class BankAccountRepositoryImpl implements BankAccountRepository {
  final AccountLocalDatasource _accountLocalDataSource;
  final AccountRemoteDatasource _accountRemoteDataSource;
  final OperationLocalDatasource _operationLocalDataSource;
  final ConnectivityService _connectivityService;
  final SyncService _syncService;

  BankAccountRepositoryImpl(
    this._accountLocalDataSource,
    this._accountRemoteDataSource,
    this._operationLocalDataSource,
    this._connectivityService,
    this._syncService,
  );

  // Вспомогательная функция для маппинга DioException в Failure
  Failure _mapDioExceptionToFailure(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      return Failure('Нет соединения с интернетом или таймаут.');
    }
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final errorMessage =
          e.response!.data?['message'] as String? ?? 'Произошла ошибка сервера';
      return Failure('Ошибка сервера $statusCode: $errorMessage');
    }
    return Failure('Неизвестная сетевая ошибка: ${e.message}');
  }

  // Вспомогательная функция для маппинга любых других исключений в Failure
  Failure _mapLocalExceptionToFailure(Object e) {
    return Failure('Ошибка при обработке локальных данных: ${e.toString()}');
  }

  /// Вспомогательный метод для получения счетов только из локальной БД.
  Future<Either<Failure, List<AccountModel>>> _getAccountsLocally() async {
    try {
      final localAccounts = await _accountLocalDataSource.getAllAccounts();
      return right(localAccounts);
    } catch (e) {
      return left(_mapLocalExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, AccountModel>> addBankAccount(
    AccountCreateModel requestNewAccount,
  ) async {
    try {
      // 1. Сохраняем новую учетную запись в локальную БД.
      // Возвращает AccountModel с локальным ID.
      final localAccount = await _accountLocalDataSource.addAccount(
        requestNewAccount,
      );

      // 2. Логируем операцию "создать" в OperationTable.
      final operationId = const Uuid().v4();
      await _operationLocalDataSource.insertOperation(
        operationId: operationId,
        type: 'create',
        entity: 'account',
        entityLocalId: localAccount.id, // Сохраняем локальный ID
        data: jsonEncode(requestNewAccount.toJson()), // Данные запроса
      );

      // 3. Пытаемся синхронизировать ожидающие операции сразу.
      final syncResult = await _syncService.syncPendingOperations();
      if (syncResult.isLeft()) {
        // Если синхронизация не удалась (например, нет сети),
        // просто возвращаем локальную модель. Операция останется в очереди.
        print(
          'Синхронизация создания счета не удалась, возвращаем локальную модель.',
        );
        return right(localAccount);
      }
      // Если синхронизация была успешной, _syncPendingOperations должен был
      // обновить serverId в локальной модели и удалить операцию.
      // Получаем обновленную локальную модель (с serverId).
      final updatedLocalAccount = await _accountLocalDataSource.getAccountById(
        localAccount.id,
      );
      return right(
        updatedLocalAccount ?? localAccount,
      ); // Вернем обновленный или исходный
    } on Exception catch (e) {
      return left(_mapLocalExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, AccountResponseModel>> getBankAccountById(
    int id,
  ) async {
    try {
      // 1. Сначала пытаемся синхронизировать ожидающие операции.
      final syncResult = await _syncService.syncPendingOperations();
      if (syncResult.isLeft()) {
        // Если синхронизация не удалась (вероятно, из-за отсутствия сети),
        // возвращаем ошибку, так как этот метод требует актуальных данных с сервера.
        return left(
          Failure(
            'Нет соединения для получения полной информации о счете. Попробуйте позже.',
          ),
        );
      }

      // 2. Если синхронизация успешна или не было ожидающих операций,
      // получаем данные с сервера (если есть связь).
      if (await _connectivityService.isConnected()) {
        try {
          // ID сервера - это String, поэтому преобразуем int id в String.
          // Предполагаем, что id, переданный в этот метод, может быть локальным ID,
          // и нам нужно получить serverId для запроса к удаленному источнику.
          // Или же, что UI уже работает с serverId после первоначальной синхронизации.
          // Для надежности, сначала попробуем найти account по локальному ID,
          // чтобы получить его serverId.
          final localAccount = await _accountLocalDataSource.getAccountById(id);
          if (localAccount?.id == null) {
            // localAccount.id здесь уже serverId
            return left(
              Failure('Счет не найден локально для получения Server ID.'),
            );
          }
          final remoteAccount = await _accountRemoteDataSource.getAccountById(
            localAccount!.id.toString(),
          );
          // Обновляем локальные данные основной информации о счете
          await _accountLocalDataSource.updateAccountFromResponse(
            remoteAccount,
          );
          return right(remoteAccount);
        } on DioException catch (e) {
          // Если ошибка сети после попытки синхронизации, возвращаем ошибку.
          return left(_mapDioExceptionToFailure(e));
        } on Exception catch (e) {
          return left(_mapLocalExceptionToFailure(e));
        }
      } else {
        // Нет сети после попытки синхронизации, возвращаем ошибку.
        return left(
          Failure('Нет соединения для получения полной информации о счете.'),
        );
      }
    } on Exception catch (e) {
      return left(_mapLocalExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, AccountModel>> updateBankAccount(
    int accountId,
    AccountUpdateModel requestUpdatedAccount,
  ) async {
    try {
      // 1. Обновляем счет в локальной БД.
      final updatedLocalAccount = await _accountLocalDataSource.updateAccount(
        accountId,
        requestUpdatedAccount,
      );

      // 2. Логируем операцию "обновить" в OperationTable.
      final operationId = const Uuid().v4();
      await _operationLocalDataSource.insertOperation(
        operationId: operationId,
        type: 'update',
        entity: 'account',
        entityLocalId: accountId, // Локальный ID обновляемого счета
        data: jsonEncode(requestUpdatedAccount.toJson()), // Данные запроса
      );

      // 3. Пытаемся синхронизировать ожидающие операции сразу.
      final syncResult = await _syncService.syncPendingOperations();
      if (syncResult.isLeft()) {
        // Если синхронизация не удалась, возвращаем локальную модель.
        print(
          'Синхронизация обновления счета не удалась, возвращаем локальную модель.',
        );
        return right(updatedLocalAccount);
      }
      // Если синхронизация успешна, операция должна быть удалена,
      // и локальная модель уже должна быть актуальной.
      return right(updatedLocalAccount);
    } on Exception catch (e) {
      return left(_mapLocalExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, AccountHistoryResponseModel>> getAccountHistory(
    int accountId,
  ) async {
    // Согласно твоему требованию: "если нет связи то ничего не будет".
    // Этот метод не имеет локальной реализации и полагается исключительно на удаленные данные.
    try {
      // 1. Попытка синхронизировать ожидающие операции.
      final syncResult = await _syncService.syncPendingOperations();
      if (syncResult.isLeft()) {
        // Если синхронизация завершилась с ошибкой (вероятно, из-за отсутствия сети),
        // или если просто нет сети, мы сразу возвращаем ошибку.
        return left(Failure('Нет соединения для получения истории счета.'));
      }

      // 2. Если синхронизация прошла или нет ожидающих операций, пытаемся получить с сервера.
      if (await _connectivityService.isConnected()) {
        try {
          // Получаем serverId аккаунта по локальному ID
          final localAccount = await _accountLocalDataSource.getAccountById(
            accountId,
          );
          if (localAccount?.id == null) {
            // localAccount.id здесь уже serverId
            return left(
              Failure('Счет не найден локально для получения Server ID.'),
            );
          }
          final remoteHistory = await _accountRemoteDataSource
              .getAccountHistory(localAccount!.id.toString());
          return right(remoteHistory);
        } on DioException catch (e) {
          return left(_mapDioExceptionToFailure(e));
        } on Exception catch (e) {
          return left(_mapLocalExceptionToFailure(e));
        }
      } else {
        // Если нет сети после попытки синхронизации, возвращаем ошибку.
        return left(Failure('Нет соединения для получения истории счета.'));
      }
    } on Exception catch (e) {
      return left(_mapLocalExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<BalanceDataPoint>>> getBalanceHistoryForChart(
    int accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Согласно твоему требованию: "работает только при наличии интернет-соединения,
    // всегда запрашивая историю с сервера и не кэшируя её локально".
    try {
      // 1. Сначала пытаемся синхронизировать ожидающие операции.
      final syncResult = await _syncService.syncPendingOperations();
      if (syncResult.isLeft()) {
        // Если синхронизация не удалась (вероятно, из-за отсутствия сети),
        // возвращаем ошибку, так как этот метод требует актуальных данных с сервера.
        return left(
          Failure('Нет соединения для получения истории баланса для графика.'),
        );
      }

      // 2. Если синхронизация прошла или не было ожидающих операций,
      // получаем данные с сервера (если есть связь).
      if (await _connectivityService.isConnected()) {
        try {
          // Получаем serverId аккаунта по локальному ID
          final localAccount = await _accountLocalDataSource.getAccountById(
            accountId,
          );
          if (localAccount?.id == null) {
            // localAccount.id здесь уже serverId
            return left(
              Failure('Счет не найден локально для получения Server ID.'),
            );
          }
          // Запрашиваем историю счета с сервера.
          final remoteHistoryResponse = await _accountRemoteDataSource
              .getAccountHistory(localAccount!.id.toString());

          // Получаем текущий баланс счета с сервера (если AccountResponseModel содержит его)
          final AccountResponseModel accountResponse =
              await _accountRemoteDataSource.getAccountById(
                localAccount.id.toString(),
              );
          final double initialBalance =
              double.tryParse(accountResponse.balance) ?? 0.0;

          // Фильтруем и сортируем историю, полученную с сервера
          final filteredAndSortedHistory =
              remoteHistoryResponse.history
                  .where(
                    (h) =>
                        h.changeTimestamp.isAfter(
                          startDate.subtract(const Duration(days: 1)),
                        ) &&
                        h.changeTimestamp.isBefore(
                          endDate.add(const Duration(days: 1)),
                        ),
                  )
                  .toList()
                ..sort(
                  (a, b) => a.changeTimestamp.compareTo(b.changeTimestamp),
                );

          final List<BalanceDataPoint> dailyBalances = [];

          // Если история пуста, возвращаем текущий баланс на все дни
          if (filteredAndSortedHistory.isEmpty) {
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

          double currentBalance = initialBalance;
          final Map<DateTime, double> dailyBalancesMap = {};

          // Определяем баланс на начало startDate
          for (final historyEntry in filteredAndSortedHistory) {
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
                  double.tryParse(historyEntry.newState.balance) ??
                  currentBalance;
            } else {
              break;
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
                  );

            if (dayHistory.isNotEmpty) {
              currentBalance =
                  double.tryParse(dayHistory.last.newState.balance) ??
                  currentBalance;
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
        } on DioException catch (e) {
          return left(_mapDioExceptionToFailure(e));
        } on Exception catch (e) {
          return left(_mapLocalExceptionToFailure(e));
        }
      } else {
        // Если нет сети после попытки синхронизации, возвращаем ошибку.
        return left(
          Failure('Нет соединения для получения истории баланса для графика.'),
        );
      }
    } on Exception catch (e) {
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
}

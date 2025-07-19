import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import 'package:yandex_shmr_hw/core/error/failure.dart';
import 'package:yandex_shmr_hw/core/network/connectivity_service.dart';
import 'package:yandex_shmr_hw/core/sync/sync_service.dart';
import 'package:yandex_shmr_hw/features/finance/data/local_datasource/operation_local_datasource.dart';
import 'package:yandex_shmr_hw/features/finance/data/local_datasource/transaction_local_datasource.dart';
import 'package:yandex_shmr_hw/features/finance/data/mocks.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_brief_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/category/category_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/enums/currency.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_request_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_response_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/remote_datasource/account_remote_ds.dart';
import 'package:yandex_shmr_hw/features/finance/data/remote_datasource/transaction_remote_ds.dart';
import 'package:yandex_shmr_hw/features/finance/domain/repository/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDatasource _transactionLocalDataSource;
  final TransactionRemoteDatasource _transactionRemoteDataSource;
  final AccountRemoteDatasource _accountLocalDataSource;
  final OperationLocalDatasource
  _operationLocalDataSource; // Все еще нужен для логирования операций
  final ConnectivityService _connectivityService;
  final SyncService _syncService; // Новый сервис синхронизации

  TransactionRepositoryImpl(
    this._transactionLocalDataSource,
    this._transactionRemoteDataSource,
    this._operationLocalDataSource,
    this._connectivityService,
    this._syncService,
    this._accountLocalDataSource, // Инжектируем SyncService
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

  @override
  Future<Either<Failure, TransactionModel>> addTransaction(
    TransactionRequestModel transaction,
  ) async {
    try {
      // 1. Сохраняем новую транзакцию в локальную БД.
      final localTransaction = await _transactionLocalDataSource.addTransaction(
        transaction,
      );

      // 2. Логируем операцию "создать" в OperationTable.
      final operationId = const Uuid().v4();
      await _operationLocalDataSource.insertOperation(
        operationId: operationId,
        type: 'create',
        entity: 'transaction',
        entityLocalId: localTransaction.id, // Локальный ID транзакции
        data: jsonEncode(transaction.toJson()), // Данные запроса
      );

      // 3. Пытаемся синхронизировать ожидающие операции сразу через SyncService.
      final syncResult = await _syncService.syncPendingOperations();
      if (syncResult.isLeft()) {
        print(
          'Синхронизация создания транзакции не удалась, возвращаем локальную модель.',
        );
        return right(localTransaction); // Операция останется в очереди
      }
      // Если синхронизация была успешной, SyncService должен был
      // обновить serverId в локальной модели и удалить операцию.
      // Получаем обновленную локальную модель (с serverId).
      final updatedLocalTransactionResponse = await _transactionLocalDataSource
          .getTransactionById(localTransaction.id);
      // getTransactionById возвращает TransactionResponseModel, нам нужна TransactionModel
      return right(
        TransactionModel(
          id: updatedLocalTransactionResponse.id,
          accountId: updatedLocalTransactionResponse.account.id,
          categoryId: updatedLocalTransactionResponse.category.id,
          amount: '',
          transactionDate: updatedLocalTransactionResponse.transactionDate,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    } on Exception catch (e) {
      return left(_mapLocalExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, TransactionResponseModel>> getTransactionById({
    required int transactionId,
  }) async {
    try {
      // 1. Сначала пытаемся синхронизировать ожидающие операции через SyncService.
      final syncResult = await _syncService.syncPendingOperations();
      if (syncResult.isLeft()) {
        print(
          'Синхронизация ожидающих операций не удалась при получении транзакции, пробуем локально.',
        );
        return await _getTransactionByIdLocally(transactionId);
      }

      // 2. Если есть соединение, пытаемся получить актуальные данные с бэкенда.
      if (await _connectivityService.isConnected()) {
        try {
          final localTransaction = await _transactionLocalDataSource
              .getTransactionById(transactionId);
          if (localTransaction.id != transactionId) {
            return left(
              Failure('Транзакция не найдена локально или не имеет Server ID.'),
            );
          }
          final remoteTransaction = await _transactionRemoteDataSource
              .getTransactionById(localTransaction.id.toString());
          return right(remoteTransaction);
        } on DioException catch (e) {
          print(
            'Ошибка при загрузке транзакции с сервера, используем локальные данные.',
          );
          return await _getTransactionByIdLocally(transactionId);
        } on Exception catch (e) {
          print(
            'Неизвестная ошибка при загрузке транзакции с сервера, используем локальные данные: ${e.toString()}',
          );
          return await _getTransactionByIdLocally(transactionId);
        }
      } else {
        print('Нет сети, получаем транзакцию локально.');
        return await _getTransactionByIdLocally(transactionId);
      }
    } catch (e) {
      return left(_mapLocalExceptionToFailure(e));
    }
  }

  /// Вспомогательный метод для получения транзакции только из локальной БД.
  Future<Either<Failure, TransactionResponseModel>> _getTransactionByIdLocally(
    int transactionId,
  ) async {
    try {
      final localTransaction = await _transactionLocalDataSource
          .getTransactionById(transactionId);
      return right(localTransaction);
    } catch (e) {
      return left(_mapLocalExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, TransactionResponseModel>> updateTransaction(
    int transactionId,
    TransactionRequestModel transaction,
  ) async {
    try {
      // 1. Обновляем транзакцию в локальной БД.
      final updatedLocalTransaction = await _transactionLocalDataSource
          .updateTransaction(transactionId, transaction);

      // 2. Логируем операцию "обновить" в OperationTable.
      final operationId = const Uuid().v4();
      await _operationLocalDataSource.insertOperation(
        operationId: operationId,
        type: 'update',
        entity: 'transaction',
        entityLocalId: transactionId,
        data: jsonEncode(transaction.toJson()),
      );

      // 3. Пытаемся синхронизировать ожидающие операции сразу через SyncService.
      final syncResult = await _syncService.syncPendingOperations();
      if (syncResult.isLeft()) {
        print(
          'Синхронизация обновления транзакции не удалась, возвращаем локальную модель.',
        );
        return right(
          await _transactionLocalDataSource.getTransactionById(transactionId),
        );
      }
      return right(
        await _transactionLocalDataSource.getTransactionById(transactionId),
      );
    } on Exception catch (e) {
      return left(_mapLocalExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(int transactionId) async {
    try {
      // 1. Логируем операцию "удалить" в OperationTable.
      final operationId = const Uuid().v4();
      await _operationLocalDataSource.insertOperation(
        operationId: operationId,
        type: 'delete',
        entity: 'transaction',
        entityLocalId: transactionId,
        data: '{}',
      );

      // 2. Удаляем транзакцию из локальной БД.
      await _transactionLocalDataSource.deleteTransaction(transactionId);

      // 3. Пытаемся синхронизировать ожидающие операции сразу через SyncService.
      final syncResult = await _syncService.syncPendingOperations();
      if (syncResult.isLeft()) {
        print('Синхронизация удаления транзакции не удалась.');
        return right(null);
      }
      return right(null);
    } on Exception catch (e) {
      return left(_mapLocalExceptionToFailure(e));
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
      // 1. Сначала пытаемся синхронизировать ожидающие операции через SyncService.
      final syncResult = await _syncService.syncPendingOperations();
      if (syncResult.isLeft()) {
        print(
          'Синхронизация ожидающих операций не удалась при получении транзакций по счету, пробуем локально.',
        );
        return await _getAccountTransactionsLocally(
          accountId: accountId,
          startDate: startDate,
          endDate: endDate,
        );
      }

      // 2. Если есть соединение, пытаемся получить актуальные данные с бэкенда.
      if (await _connectivityService.isConnected()) {
        try {
          final localAccount = await _accountLocalDataSource.getAccountById(
            accountId.toString(),
          );

          final remoteTransactions = await _transactionRemoteDataSource
              .getAccountTransactions(
                accountId: localAccount.id.toString(),
                startDate: startDate!,
                endDate: endDate!,
              );
          return right(remoteTransactions);
        } on DioException catch (e) {
          print(
            'Ошибка при загрузке транзакций по счету с сервера, используем локальные данные.',
          );
          return await _getAccountTransactionsLocally(
            accountId: accountId,
            startDate: startDate,
            endDate: endDate,
          );
        } on Exception catch (e) {
          print(
            'Неизвестная ошибка при загрузке транзакций по счету с сервера, используем локальные данные: ${e.toString()}',
          );
          return await _getAccountTransactionsLocally(
            accountId: accountId,
            startDate: startDate,
            endDate: endDate,
          );
        }
      } else {
        print('Нет сети, получаем транзакции по счету локально.');
        return await _getAccountTransactionsLocally(
          accountId: accountId,
          startDate: startDate,
          endDate: endDate,
        );
      }
    } catch (e) {
      return left(_mapLocalExceptionToFailure(e));
    }
  }

  /// Вспомогательный метод для получения транзакций по счету только из локальной БД.
  Future<Either<Failure, List<TransactionResponseModel>>>
  _getAccountTransactionsLocally({
    required int accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final localTransactions = await _transactionLocalDataSource
          .getAccountTransactions(
            accountId: accountId,
            startDate: startDate,
            endDate: endDate,
          );
      return right(localTransactions);
    } catch (e) {
      return left(_mapLocalExceptionToFailure(e));
    }
  }

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
}

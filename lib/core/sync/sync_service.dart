import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:yandex_shmr_hw/core/error/failure.dart';
import 'package:yandex_shmr_hw/core/network/connectivity_service.dart';
import 'package:yandex_shmr_hw/features/finance/data/db/database.dart';
import 'package:yandex_shmr_hw/features/finance/data/local_datasource/account_local_datasource.dart';
import 'package:yandex_shmr_hw/features/finance/data/local_datasource/operation_local_datasource.dart';
import 'package:yandex_shmr_hw/features/finance/data/local_datasource/transaction_local_datasource.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_create_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_update_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_request_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/remote_datasource/account_remote_ds.dart';
import 'package:yandex_shmr_hw/features/finance/data/remote_datasource/transaction_remote_ds.dart';

/// Сервис, отвечающий за синхронизацию ожидающих операций с бэкендом.
/// Централизует логику differential sync.
class SyncService {
  final OperationLocalDatasource _operationLocalDataSource;
  final ConnectivityService _connectivityService;
  final AccountLocalDatasource _accountLocalDataSource;
  final AccountRemoteDatasource _accountRemoteDataSource;
  final TransactionLocalDatasource _transactionLocalDataSource;
  final TransactionRemoteDatasource _transactionRemoteDataSource;

  SyncService(
    this._operationLocalDataSource,
    this._connectivityService,
    this._accountLocalDataSource,
    this._accountRemoteDataSource,
    this._transactionLocalDataSource,
    this._transactionRemoteDataSource,
  );

  // Вспомогательная функция для маппинга DioException в Failure
  // NOTE: В идеале, эту функцию следует вынести в общую утилиту или часть общего слоя обработки ошибок.
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
  // NOTE: В идеале, эту функцию следует вынести в общую утилиту или часть общего слоя обработки ошибок.
  Failure _mapLocalExceptionToFailure(Object e) {
    return Failure('Ошибка при обработке локальных данных: ${e.toString()}');
  }

  /// Метод для попытки синхронизации всех ожидающих операций с бэкендом.
  /// Возвращает true, если все ожидающие операции успешно синхронизированы, false в противном случае.
  /// При сетевой ошибке возвращает Left(Failure), оставляя операции в очереди.
  Future<Either<Failure, bool>> syncPendingOperations() async {
    if (!await _connectivityService.isConnected()) {
      return right(false); // Нет соединения, не пытаемся синхронизировать
    }

    try {
      final pendingOperations = await _operationLocalDataSource
          .getPendingOperations();

      for (final operation in pendingOperations) {
        bool success = false;
        try {
          switch (operation.entity) {
            case 'account':
              success = await _syncAccountOperation(operation);
              break;
            case 'transaction':
              success = await _syncTransactionOperation(operation);
              break;
            case 'category':
              // Категории обычно не изменяются пользователем напрямую.
              // Если в будущем потребуется синхронизация категорий,
              // нужно будет добавить _syncCategoryOperation.
              print(
                'Операции с категориями не поддерживаются для синхронизации в этом сервисе.',
              );
              continue; // Пропускаем, если нет логики синхронизации категорий
            default:
              print(
                'Неизвестная сущность для синхронизации: ${operation.entity}',
              );
              continue;
          }

          if (success) {
            await _operationLocalDataSource.deleteOperation(
              operation.operationId,
            );
          } else {
            // Если операция не удалась (например, не найдена на сервере или зависимость не синхронизирована),
            // она остается в списке для следующей попытки или ручной обработки.
            print(
              'Не удалось синхронизировать операцию ${operation.operationId} (тип: ${operation.type}, сущность: ${operation.entity}).',
            );
          }
        } on DioException catch (e) {
          // Если сетевая ошибка, логируем и прекращаем синхронизацию, возвращая ошибку.
          // Операции остаются в очереди.
          print(
            'Ошибка синхронизации операции ${operation.operationId}: ${_mapDioExceptionToFailure(e).message}',
          );
          return left(_mapDioExceptionToFailure(e));
        } catch (e) {
          // Непредвиденная ошибка при обработке одной операции, логируем и прекращаем.
          print(
            'Непредвиденная ошибка синхронизации операции ${operation.operationId}: ${e.toString()}',
          );
          return left(_mapLocalExceptionToFailure(e));
        }
      }
      return right(
        true,
      ); // Все операции успешно синхронизированы (или не было ожидающих)
    } on DioException catch (e) {
      // Общая сетевая ошибка при получении списка операций, или если DioException пробросился из цикла
      return left(_mapDioExceptionToFailure(e));
    } on Exception catch (e) {
      // Общая локальная ошибка при получении списка операций
      return left(_mapLocalExceptionToFailure(e));
    }
  }

  /// Синхронизирует операцию со счетом (создание, обновление, удаление).
  Future<bool> _syncAccountOperation(OperationDbModel operation) async {
    final data = jsonDecode(operation.data);
    switch (operation.type) {
      case 'create':
        final remoteModel = await _accountRemoteDataSource.createAccount(
          AccountCreateModel.fromJson(data),
        );
        await _accountLocalDataSource.updateAccountServerId(
          operation.entityLocalId!,
          remoteModel.id.toString(),
        );
        return true;
      case 'update':
        final updateModel = AccountUpdateModel.fromJson(data);
        final localAccount = await _accountLocalDataSource.getAccountById(
          operation.entityLocalId!,
        );
        if (localAccount?.id == null) {
          print(
            'Аккаунт с локальным ID ${operation.entityLocalId} не найден или не имеет serverId для обновления.',
          );
          return false;
        }
        await _accountRemoteDataSource.updateAccount(
          localAccount!.id.toString(),
          updateModel,
        );
        return true;

      default:
        print('Неизвестный тип операции для аккаунта: ${operation.type}');
        return false;
    }
  }

  /// Синхронизирует операцию с транзакцией (создание, обновление, удаление).
  Future<bool> _syncTransactionOperation(OperationDbModel operation) async {
    final data = jsonDecode(operation.data);
    switch (operation.type) {
      case 'create':
        final requestModel = TransactionRequestModel.fromJson(data);
        final account = await _accountLocalDataSource.getAccountById(
          requestModel.accountId,
        );
        if (account?.id == null) {
          print(
            'Транзакция ${operation.operationId} не может быть синхронизирована: связанный счет (локальный ID ${requestModel.accountId}) не имеет serverId.',
          );
          return false;
        }
        final remoteRequestModel = requestModel.copyWith(
          accountId: account!.id,
        );
        final remoteModel = await _transactionRemoteDataSource
            .createTransaction(remoteRequestModel);
        await _transactionLocalDataSource.updateTransactionServerId(
          operation.entityLocalId!,
          remoteModel.id.toString(),
        );
        return true;
      case 'update':
        final requestModel = TransactionRequestModel.fromJson(data);
        final localTransaction = await _transactionLocalDataSource
            .getTransactionById(operation.entityLocalId!);
        if (localTransaction.id != operation.entityLocalId!) {
          print(
            'Транзакция с локальным ID ${operation.entityLocalId} не найдена или не имеет serverId для обновления.',
          );
          return false;
        }
        final account = await _accountLocalDataSource.getAccountById(
          requestModel.accountId,
        );
        if (account?.id == null) {
          print(
            'Транзакция ${operation.operationId} не может быть обновлена: связанный счет не имеет serverId.',
          );
          return false;
        }
        final remoteRequestModel = requestModel.copyWith(
          accountId: account!.id,
        );
        await _transactionRemoteDataSource.updateTransaction(
          localTransaction.id.toString(),
          remoteRequestModel,
        );
        return true;
      case 'delete':
        final localTransaction = await _transactionLocalDataSource
            .getTransactionById(operation.entityLocalId!);
        if (localTransaction.id != operation.entityLocalId!) {
          print(
            'Транзакция с локальным ID ${operation.entityLocalId} не найдена или не имеет serverId для удаления.',
          );
          return false;
        }
        await _transactionRemoteDataSource.deleteTransaction(
          localTransaction.id.toString(),
        );
        return true;
      default:
        print('Неизвестный тип операции для транзакции: ${operation.type}');
        return false;
    }
  }
}

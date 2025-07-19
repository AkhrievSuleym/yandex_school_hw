import 'package:dio/dio.dart';
import 'package:yandex_shmr_hw/core/network/api_client.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_request_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_response_model.dart';

class TransactionRemoteDatasource {
  final ApiClient _apiClient;

  TransactionRemoteDatasource(this._apiClient);

  /// Создает новую транзакцию на бэкенде.
  Future<TransactionModel> createTransaction(
    TransactionRequestModel transaction,
  ) async {
    try {
      final response = await _apiClient.createTransaction(transaction.toJson());
      return TransactionModel.fromJson(response.data);
    } on DioException {
      rethrow; // Перебрасываем ошибку выше для централизованной обработки
    }
  }

  /// Получает детальную информацию о транзакции по её ID.
  Future<TransactionResponseModel> getTransactionById(String id) async {
    try {
      final response = await _apiClient.getTransaction(id);
      return TransactionResponseModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  /// Обновляет существующую транзакцию на бэкенде.
  Future<TransactionModel> updateTransaction(
    String id,
    TransactionRequestModel
    transaction, // Используем TransactionRequestModel для обновляемых данных
  ) async {
    try {
      final response = await _apiClient.updateTransaction(
        id,
        transaction.toJson(),
      );
      return TransactionModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  /// Удаляет транзакцию с бэкенда по её ID.
  Future<void> deleteTransaction(String id) async {
    try {
      await _apiClient.deleteTransaction(id);
    } on DioException {
      rethrow;
    }
  }

  /// Получает список транзакций для конкретного счета за указанный период.
  Future<List<TransactionResponseModel>> getAccountTransactions({
    required String accountId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _apiClient.getAccountTransactionsByPeriod(
        accountId: accountId,
        startDate: startDate,
        endDate: endDate,
      );
      // Ответ может быть списком Map, поэтому маппим каждый элемент.
      return (response.data as List)
          .map((json) => TransactionResponseModel.fromJson(json))
          .toList();
    } on DioException {
      rethrow;
    }
  }
}

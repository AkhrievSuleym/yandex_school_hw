import 'package:dio/dio.dart';
import 'package:yandex_shmr_hw/core/network/api_client.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_create_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_history_response_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_response_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_update_model.dart';

class AccountRemoteDatasource {
  final ApiClient _apiClient;

  AccountRemoteDatasource(this._apiClient);

  @override
  Future<AccountModel> createAccount(AccountCreateModel account) async {
    try {
      final response = await _apiClient.createAccount(account.toJson());
      return AccountModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<AccountResponseModel> getAccountById(String id) async {
    try {
      final response = await _apiClient.getAccount(id);
      return AccountResponseModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<AccountModel> updateAccount(
    String id,
    AccountUpdateModel account,
  ) async {
    try {
      final response = await _apiClient.updateAccount(id, account.toJson());
      return AccountModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<AccountHistoryResponseModel> getAccountHistory(String id) async {
    try {
      final response = await _apiClient.getAccountHistory(id);
      return AccountHistoryResponseModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_history_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/enums/currency.dart';

part 'account_history_response_model.freezed.dart';
part 'account_history_response_model.g.dart';

@freezed
class AccountHistoryResponseModel with _$AccountHistoryResponseModel {
  const factory AccountHistoryResponseModel({
    required int accountid,
    required String accountname,
    required Currency currency,
    required String currentBalance,
    required AccountHistoryModel history,
  }) = _AccountHistoryResponseModel;

  factory AccountHistoryResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AccountHistoryResponseModelFromJson(json);
}

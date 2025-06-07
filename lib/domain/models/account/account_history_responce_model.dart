import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yandex_shmr_hw/domain/models/account/account_history_model.dart';
import 'package:yandex_shmr_hw/domain/models/enums/currency.dart';

part 'account_history_responce_model.freezed.dart';
part 'account_history_responce_model.g.dart';

@freezed
class AccountHistoryResponceModel with _$AccountHistoryResponceModel {
  const factory AccountHistoryResponceModel({
    required int accountid,
    required String accountname,
    required Currency currency,
    required String currentBalance,
    required AccountHistoryModel history,
  }) = _AccountHistoryResponceModel;

  factory AccountHistoryResponceModel.fromJson(Map<String, dynamic> json) =>
      _$AccountHistoryResponceModelFromJson(json);
}

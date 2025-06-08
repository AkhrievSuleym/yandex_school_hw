import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yandex_shmr_hw/features/finance/domain/models/account/account_state_model.dart';
import 'package:yandex_shmr_hw/features/finance/domain/models/enums/change_type.dart';

part 'account_history_model.freezed.dart';
part 'account_history_model.g.dart';

@freezed
class AccountHistoryModel with _$AccountHistoryModel {
  const factory AccountHistoryModel({
    required int id,
    required int accountId,
    required ChangeType changeType,
    required AccountStateModel previousState,
    required AccountStateModel newState,
    required DateTime changeTimestamp,
    required DateTime createdAt,
  }) = _AccountHistoryModel;

  factory AccountHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$AccountHistoryModelFromJson(json);
}

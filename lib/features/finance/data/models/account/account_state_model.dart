import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/enums/currency.dart';

part 'account_state_model.freezed.dart';
part 'account_state_model.g.dart';

@freezed
class AccountStateModel with _$AccountStateModel {
  const factory AccountStateModel({
    required int id,
    required String name,
    required String balance,
    required Currency currency,
  }) = _AccountStateModel;

  factory AccountStateModel.fromJson(Map<String, dynamic> json) =>
      _$AccountStateModelFromJson(json);
}

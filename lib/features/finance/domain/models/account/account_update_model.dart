import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yandex_shmr_hw/domain/models/enums/currency.dart';

part 'account_update_model.freezed.dart';
part 'account_update_model.g.dart';

@freezed
class AccountUpdateModel with _$AccountUpdateModel {
  const factory AccountUpdateModel({
    required String name,
    required String balance,
    required Currency currency,
  }) = _AccountUpdateModel;

  factory AccountUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$AccountUpdateModelFromJson(json);
}

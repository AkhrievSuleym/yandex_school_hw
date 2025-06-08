import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yandex_shmr_hw/domain/models/enums/currency.dart';

part 'account_create_model.freezed.dart';
part 'account_create_model.g.dart';

@freezed
class AccountCreateModel with _$AccountCreateModel {
  const factory AccountCreateModel({
    required String name,
    required String balance,
    required Currency currency,
  }) = _AccountCreateModel;

  factory AccountCreateModel.fromJson(Map<String, dynamic> json) =>
      _$AccountCreateModelFromJson(json);
}

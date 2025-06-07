import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yandex_shmr_hw/domain/models/enums/currency.dart';

part 'account_model.freezed.dart';
part 'account_model.g.dart';

@freezed
class AccountModel with _$AccountModel {
  const factory AccountModel({
    required int id,
    required int userId,
    required String name,
    required String balance,
    required Currency currency,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AccountModel;

  factory AccountModel.fromJson(Map<String, dynamic> json) =>
      _$AccountModelFromJson(json);
}

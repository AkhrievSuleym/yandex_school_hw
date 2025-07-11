import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/enums/currency.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/stat/stat_item.dart';

part 'account_response_model.freezed.dart';
part 'account_response_model.g.dart';

@freezed
class AccountResponseModel with _$AccountResponseModel {
  const factory AccountResponseModel({
    required int id,
    required String name,
    required String balance,
    required Currency currency,
    required List<StatItem> incomeStats,
    required List<StatItem> expenseStats,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AccountResponseModel;

  factory AccountResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AccountResponseModelFromJson(json);
}

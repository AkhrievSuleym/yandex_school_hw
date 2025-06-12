import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/enums/currency.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/stat/stat_item.dart';

part 'account_response_model.freezed.dart';
part 'account_response_model.g.dart';

@freezed
class AccountResponseModel with _$AccountResponse {
  const factory AccountResponseModel({
    required int id,
    required String name,
    required String balance,
    required Currency currency,
    required StatItem incomeStats,
    required StatItem expenseStats,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AccountResponse;

  factory AccountResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AccountResponseFromJson(json);
}

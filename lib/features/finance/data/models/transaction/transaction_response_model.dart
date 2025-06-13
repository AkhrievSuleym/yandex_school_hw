import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_brief_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/category/category_model.dart';

part 'transaction_response_model.freezed.dart';
part 'transaction_response_model.g.dart';

@freezed
class TransactionResponseModel with _$TransactionResponseModel {
  @JsonSerializable(explicitToJson: true)
  const factory TransactionResponseModel({
    required int id,
    required AccountBriefModel account,
    required CategoryModel category,
    required String amount,
    required DateTime transactionDate,
    String? comment,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TransactionResponseModel;

  factory TransactionResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionResponseModelFromJson(json);
}

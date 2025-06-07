import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:yandex_shmr_hw/domain/models/enums/currency.dart';

part 'account_brief_model.freezed.dart';
part 'account_brief_model.g.dart';

@freezed
class AccountBriefModel with _$AccountBriefModel {
  const factory AccountBriefModel({
    required int id,
    required String name,
    required String balance,
    required Currency currency,
  }) = _AccountBriefModel;

  factory AccountBriefModel.fromJson(Map<String, dynamic> json) =>
      _$AccountBriefModelFromJson(json);
}

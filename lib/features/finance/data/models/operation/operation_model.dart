import 'package:freezed_annotation/freezed_annotation.dart';

part 'operation_model.freezed.dart';
part 'operation_model.g.dart';

@freezed
class OperationModel with _$OperationModel {
  const factory OperationModel({
    required String id,
    required String type,
    required Map<String, dynamic> data,
    required DateTime timestamp,
    required String status,
  }) = _OperationModel;

  factory OperationModel.fromJson(Map<String, dynamic> json) =>
      _$OperationModelFromJson(json);
}

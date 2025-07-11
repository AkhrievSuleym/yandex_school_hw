import 'package:freezed_annotation/freezed_annotation.dart';

part 'pending_sync_event_model.freezed.dart';
part 'pending_sync_event_model.g.dart';

@freezed
class PendingSyncEventModel with _$PendingSyncEventModel {
  const factory PendingSyncEventModel({
    required int id, // Локальный ID события в очереди
    required String eventType,
    required int localEntityId,
    int? serverEntityId,
    required String? payload,
    required DateTime createdAt,
    required int retryCount,
    String? lastError,
  }) = _PendingSyncEventModel;

  factory PendingSyncEventModel.fromJson(Map<String, dynamic> json) =>
      _$PendingSyncEventModelFromJson(json);
}

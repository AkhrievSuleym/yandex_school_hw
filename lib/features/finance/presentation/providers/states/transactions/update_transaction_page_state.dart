import 'package:yandex_shmr_hw/core/error/failure.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_response_model.dart';

class UpdateTransactionPageState {
  final TransactionResponseModel? transaction;
  final bool isLoading;
  final Failure? error;
  final bool isSuccess;

  UpdateTransactionPageState({
    this.transaction,
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  UpdateTransactionPageState copyWith({
    TransactionResponseModel? transaction,
    bool? isLoading,
    Failure? error,
    bool? isSuccess,
  }) {
    return UpdateTransactionPageState(
      transaction: transaction ?? this.transaction,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

import 'package:yandex_shmr_hw/core/error/failure.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_response_model.dart';

class TransactionsPageState {
  final List<TransactionResponseModel> transactions;
  final double totalAmount;
  final bool isLoading;
  final Failure? error;

  TransactionsPageState({
    this.transactions = const [],
    this.totalAmount = 0.0,
    this.isLoading = false,
    this.error,
  });

  TransactionsPageState copyWith({
    List<TransactionResponseModel>? transactions,
    double? totalAmount,
    bool? isLoading,
    Failure? error,
  }) {
    return TransactionsPageState(
      transactions: transactions ?? this.transactions,
      totalAmount: totalAmount ?? this.totalAmount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

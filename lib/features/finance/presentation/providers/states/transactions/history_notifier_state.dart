import 'package:yandex_shmr_hw/core/error/failure.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/enums/sort_by.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_response_model.dart';

class HistoryPageState {
  final DateTime startDate;
  final DateTime endDate;
  final bool isIncome;
  final List<TransactionResponseModel> transactions;
  final bool isLoading;
  final Failure? error;
  final SortBy sortBy;

  HistoryPageState({
    required this.startDate,
    required this.endDate,
    required this.isIncome,
    this.transactions = const [],
    this.isLoading = false,
    this.error,
    this.sortBy = SortBy.date,
  });

  HistoryPageState copyWith({
    DateTime? startDate,
    DateTime? endDate,
    bool? isIncome,
    List<TransactionResponseModel>? transactions,
    bool? isLoading,
    Failure? error,
    SortBy? sortBy,
  }) {
    return HistoryPageState(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isIncome: isIncome ?? this.isIncome,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

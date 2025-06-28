import 'package:yandex_shmr_hw/core/error/failure.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/category/category_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_response_model.dart';

class GroupedCategoryTransactions {
  final CategoryModel category;
  final double totalAmount;
  final List<TransactionResponseModel>
  transactions; // Все транзакции для этой категории
  final TransactionResponseModel?
  latestTransaction; // Последняя транзакция для подзаголовка

  GroupedCategoryTransactions({
    required this.category,
    required this.totalAmount,
    required this.transactions,
    this.latestTransaction,
  });
}

class AnalysisPageState {
  final DateTime startDate;
  final DateTime endDate;
  final bool? isIncome;
  final List<TransactionResponseModel>
  allTransactions; // Все загруженные транзакции
  final List<GroupedCategoryTransactions>
  groupedTransactions; // Сгруппированные
  final bool isLoading;
  final Failure? error;

  AnalysisPageState({
    required this.startDate,
    required this.endDate,
    this.isIncome,
    this.allTransactions = const [],
    this.groupedTransactions = const [],
    this.isLoading = false,
    this.error,
  });

  AnalysisPageState copyWith({
    DateTime? startDate,
    DateTime? endDate,
    bool? isIncome,
    List<TransactionResponseModel>? allTransactions,
    List<GroupedCategoryTransactions>? groupedTransactions,
    bool? isLoading,
    Failure? error,
  }) {
    return AnalysisPageState(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isIncome: isIncome ?? this.isIncome,
      allTransactions: allTransactions ?? this.allTransactions,
      groupedTransactions: groupedTransactions ?? this.groupedTransactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

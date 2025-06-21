import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_shmr_hw/core/error/failure.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_response_model.dart';
import 'package:yandex_shmr_hw/features/finance/di/usecase_providers.dart';
import 'package:yandex_shmr_hw/features/finance/domain/usecases/transactions/get_transactions_usecase.dart';

class TransactionsScreenState {
  final List<TransactionResponseModel> transactions;
  final double totalAmount;
  final bool isLoading;
  final Failure? error;

  TransactionsScreenState({
    this.transactions = const [],
    this.totalAmount = 0.0,
    this.isLoading = false,
    this.error,
  });

  TransactionsScreenState copyWith({
    List<TransactionResponseModel>? transactions,
    double? totalAmount,
    bool? isLoading,
    Failure? error,
  }) {
    return TransactionsScreenState(
      transactions: transactions ?? this.transactions,
      totalAmount: totalAmount ?? this.totalAmount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final transactionsScreenNotifierProvider =
    StateNotifierProvider<TransactionsScreenNotifier, TransactionsScreenState>((
      ref,
    ) {
      final getTransactionsUseCase = ref.read(getTransactionsUseCaseProvider);
      return TransactionsScreenNotifier(getTransactionsUseCase);
    });

class TransactionsScreenNotifier
    extends StateNotifier<TransactionsScreenState> {
  final GetTransactionsUseCase _getTransactionsUseCase;

  TransactionsScreenNotifier(this._getTransactionsUseCase)
    : super(TransactionsScreenState()) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    // Пока используем mock.
    loadTransactions(accountId: 1, startDate: startOfDay, endDate: endOfDay);
  }

  Future<void> loadTransactions({
    required int accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    ); // Устанавливаем состояние загрузки
    final params = GetTransactionsParams(
      accountId: accountId,
      startDate: startDate,
      endDate: endDate,
    );

    final result = await _getTransactionsUseCase(params); // Вызываем Use Case

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure,
      ), // Обработка ошибки
      (transactions) {
        final total = transactions.fold(
          0.0,
          (sum, tr) => sum + double.parse(tr.amount),
        );
        state = state.copyWith(
          transactions: transactions,
          totalAmount: total,
          isLoading: false,
          error: null,
        );
      },
    );
  }
}

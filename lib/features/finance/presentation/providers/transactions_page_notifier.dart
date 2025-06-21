import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_shmr_hw/features/finance/di/usecase_providers.dart';
import 'package:yandex_shmr_hw/features/finance/domain/usecases/transactions/get_transactions_usecase.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/states/transaction_notifier_state.dart';

final transactionsPageNotifierProvider =
    StateNotifierProvider<TransactionsPageNotifier, TransactionsPageState>((
      ref,
    ) {
      final getTransactionsUseCase = ref.read(getTransactionsUseCaseProvider);
      return TransactionsPageNotifier(getTransactionsUseCase);
    });

class TransactionsPageNotifier extends StateNotifier<TransactionsPageState> {
  final GetTransactionsUseCase _getTransactionsUseCase;

  TransactionsPageNotifier(this._getTransactionsUseCase)
    : super(TransactionsPageState()) {
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

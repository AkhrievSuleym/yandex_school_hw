import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/enums/sort_by.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_response_model.dart';
import 'package:yandex_shmr_hw/features/finance/di/usecase_providers.dart';
import 'package:yandex_shmr_hw/features/finance/domain/usecases/transactions/get_transactions_usecase.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/states/history_notifier_state.dart';

final historyPageNotifierProvider =
    StateNotifierProvider<HistoryPageNotifier, HistoryPageState>((ref) {
      final getTransactionsUseCase = ref.watch(getTransactionsUseCaseProvider);
      return HistoryPageNotifier(getTransactionsUseCase);
    });

class HistoryPageNotifier extends StateNotifier<HistoryPageState> {
  final GetTransactionsUseCase _getTransactionsUseCase;

  HistoryPageNotifier(this._getTransactionsUseCase)
    : super(
        HistoryPageState(
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now(),
          isIncome: false, // Инициализация по умолчанию
        ),
      );

  void init(bool initialIsIncome) {
    state = state.copyWith(isIncome: initialIsIncome);
    _normalizeDates();
  }

  void _normalizeDates() {
    state = state.copyWith(
      startDate: DateTime(
        state.startDate.year,
        state.startDate.month,
        state.startDate.day,
      ),
      endDate: DateTime(
        state.endDate.year,
        state.endDate.month,
        state.endDate.day,
        23,
        59,
        59,
        999,
      ),
    );
  }

  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true, error: null);

    const int currentAccountId = 1;

    final params = GetTransactionsParams(
      accountId: currentAccountId,
      startDate: state.startDate, // Используем дату из состояния
      endDate: state.endDate, // Используем дату из состояния
    );

    final result = await _getTransactionsUseCase(params);

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure),
      (transactions) {
        final filteredByType = transactions.where((transaction) {
          return transaction.category.isIncome == state.isIncome;
        }).toList();

        _sortTransactions(filteredByType);

        state = state.copyWith(isLoading: false, transactions: filteredByType);
      },
    );
  }

  Future<void> setStartDate(DateTime newDate) async {
    DateTime normalizedNewDate = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
    );
    if (normalizedNewDate.isAfter(state.endDate)) {
      state = state.copyWith(
        startDate: normalizedNewDate,
        endDate: normalizedNewDate,
      );
      _normalizeDates();
    } else {
      state = state.copyWith(startDate: normalizedNewDate);
      _normalizeDates();
    }
    await loadTransactions();
  }

  Future<void> setEndDate(DateTime newDate) async {
    DateTime normalizedNewDate = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
    );
    if (normalizedNewDate.isBefore(state.startDate)) {
      state = state.copyWith(
        endDate: normalizedNewDate,
        startDate: normalizedNewDate,
      );
      _normalizeDates();
    } else {
      state = state.copyWith(endDate: normalizedNewDate);
      _normalizeDates();
    }
    await loadTransactions();
  }

  void setSortBy(SortBy newSortBy) {
    state = state.copyWith(sortBy: newSortBy);
    _sortTransactions(state.transactions);
  }

  void _sortTransactions(List<TransactionResponseModel> transactions) {
    final List<TransactionResponseModel> sortedList = List.from(transactions);
    if (state.sortBy == SortBy.date) {
      sortedList.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    } else if (state.sortBy == SortBy.amount) {
      sortedList.sort(
        (a, b) => double.parse(b.amount).compareTo(double.parse(a.amount)),
      );
    }
    state = state.copyWith(transactions: sortedList);
  }
}

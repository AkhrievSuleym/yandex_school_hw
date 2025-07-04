import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/category/category_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_response_model.dart';
import 'package:yandex_shmr_hw/features/finance/di/usecase_providers.dart';
import 'package:yandex_shmr_hw/features/finance/domain/usecases/transactions/get_transactions_usecase.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/states/transactions/analysis_page_state.dart';

final analysisPageNotifierProvider =
    StateNotifierProvider.family<
      AnalysisPageNotifier,
      AnalysisPageState,
      bool?
    >((ref, isIncomeInitial) {
      final getTransactionsUseCase = ref.watch(getTransactionsUseCaseProvider);
      return AnalysisPageNotifier(getTransactionsUseCase, isIncomeInitial);
    });

class AnalysisPageNotifier extends StateNotifier<AnalysisPageState> {
  final GetTransactionsUseCase _getTransactionsUseCase;

  AnalysisPageNotifier(this._getTransactionsUseCase, bool? isIncomeInitial)
    : super(
        AnalysisPageState(
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now(),
          isIncome: isIncomeInitial, // <-- Инициализируем isIncome
        ),
      ) {
    _normalizeDates();
    loadTransactionsAndGroup();
  }

  void _normalizeDates() {
    state = state.copyWith(
      startDate: DateTime(
        state.startDate.year,
        state.startDate.month,
        state.startDate.day,
        0,
        0,
        0,
        0,
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

  Future<void> loadTransactionsAndGroup() async {
    state = state.copyWith(isLoading: true, error: null);

    const int currentAccountId = 1;

    final params = GetTransactionsParams(
      accountId: currentAccountId,
      startDate: state.startDate,
      endDate: state.endDate,
    );

    final result = await _getTransactionsUseCase(params);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure);
      },
      (transactions) {
        final List<TransactionResponseModel> filteredTransactions = transactions
            .where((transaction) {
              if (state.isIncome == null) {
                return true; // Если isIncome null, показываем все
              }
              return transaction.category.isIncome == state.isIncome;
            })
            .toList();

        final Map<CategoryModel, List<TransactionResponseModel>> grouped = {};
        for (var tr in filteredTransactions) {
          grouped.putIfAbsent(tr.category, () => []).add(tr);
        }

        final List<GroupedCategoryTransactions> groupedList = [];
        grouped.forEach((category, transactionsList) {
          transactionsList.sort(
            (a, b) => b.transactionDate.compareTo(a.transactionDate),
          );
          final total = transactionsList.fold(
            0.0,
            (sum, tr) => sum + double.parse(tr.amount),
          );
          groupedList.add(
            GroupedCategoryTransactions(
              category: category,
              totalAmount: total,
              transactions: transactionsList,
              latestTransaction: transactionsList.isNotEmpty
                  ? transactionsList.first
                  : null,
            ),
          );
        });

        groupedList.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

        state = state.copyWith(
          isLoading: false,
          allTransactions:
              filteredTransactions, // Сохраняем уже отфильтрованные транзакции
          groupedTransactions: groupedList,
        );
      },
    );
  }

  Future<void> setStartDate(DateTime newDate) async {
    DateTime normalizedNewDate = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
      0,
      0,
      0,
      0,
    );
    if (normalizedNewDate.isAfter(state.endDate)) {
      state = state.copyWith(
        startDate: normalizedNewDate,
        endDate: normalizedNewDate.add(
          const Duration(
            hours: 23,
            minutes: 59,
            seconds: 59,
            milliseconds: 999,
          ),
        ),
      );
    } else {
      state = state.copyWith(startDate: normalizedNewDate);
    }
    _normalizeDates();
    await loadTransactionsAndGroup();
  }

  Future<void> setEndDate(DateTime newDate) async {
    DateTime normalizedNewDate = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
      23,
      59,
      59,
      999,
    );
    if (normalizedNewDate.isBefore(state.startDate)) {
      state = state.copyWith(
        endDate: normalizedNewDate,
        startDate: normalizedNewDate.subtract(
          const Duration(
            hours: 23,
            minutes: 59,
            seconds: 59,
            milliseconds: 999,
          ),
        ),
      );
    } else {
      state = state.copyWith(endDate: normalizedNewDate);
    }
    _normalizeDates();
    await loadTransactionsAndGroup();
  }

  void setIsIncome(bool? newValue) {
    state = state.copyWith(isIncome: newValue);
    loadTransactionsAndGroup(); // Перезагружаем данные с новым фильтром
  }
}

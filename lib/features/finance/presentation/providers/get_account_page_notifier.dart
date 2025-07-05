import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_history_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/balance_data_point.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/enums/change_type.dart';
import 'package:yandex_shmr_hw/features/finance/di/usecase_providers.dart';
import 'package:yandex_shmr_hw/features/finance/domain/usecases/account/get_account_history.dart';
import 'package:yandex_shmr_hw/features/finance/domain/usecases/account/get_account_usecase.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/states/account/get_account_notifier_state.dart';

final accountPageNotifierProvider =
    StateNotifierProvider<AccountPageNotifier, AccountPageState>((ref) {
      final getAccountById = ref.read(getAccountByIdUseCaseProvider);
      final getAccountHistory = ref.watch(
        getAccountHistoryUseCaseProvider,
      ); // Используем новый UseCase
      return AccountPageNotifier(getAccountById, getAccountHistory);
    });

class AccountPageNotifier extends StateNotifier<AccountPageState> {
  final GetAccountByIdUseCase _getAccountByIdUseCase;
  final GetAccountHistoryUseCase _getAccountHistoryUseCase;

  AccountPageNotifier(
    this._getAccountByIdUseCase,
    this._getAccountHistoryUseCase,
  ) : super(AccountPageState()) {
    loadAccountDetails(accountId: 1);
  }

  Future<void> loadAccountDetails({required int accountId}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getAccountByIdUseCase(
      GetAccountByIdParams(accountId: accountId),
    );

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure),
      (accountResponse) =>
          state = state.copyWith(isLoading: false, account: accountResponse),
    );
  }

  void toggleBalanceBlur() {
    state = state.copyWith(isBalanceBlurred: !state.isBalanceBlurred);
  }

  Future<void> _fetchBalanceDataForChart(int accountId) async {
    state = state.copyWith(isChartLoading: true, chartErrorMessage: null);
    try {
      final now = DateTime.now();
      final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
      DateTime startDate;

      if (state.selectedChartPeriod == ChartPeriod.daily) {
        startDate = endDate.subtract(const Duration(days: 29));
      } else {
        startDate = DateTime(now.year - 1, now.month, 1);
      }

      final historyResult = await _getAccountHistoryUseCase(
        GetAccountHistoryParams(accountId: accountId),
      );

      historyResult.fold(
        (failure) => state = state.copyWith(
          chartErrorMessage: failure.message,
          isChartLoading: false,
        ),
        (responseModel) {
          final List<AccountHistoryModel> rawHistory = responseModel.history;

          final List<BalanceDataPoint> dailyData = _calculateDailyBalances(
            rawHistory,
            startDate,
            endDate,
          );

          List<BalanceDataPoint> processedData = dailyData;
          if (state.selectedChartPeriod == ChartPeriod.monthly) {
            processedData = _aggregateMonthlyData(dailyData);
          }
          state = state.copyWith(
            chartBalanceData: processedData,
            isChartLoading: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        chartErrorMessage: e.toString(),
        isChartLoading: false,
      );
    }
  }

  // Метод для вычисления ежедневного баланса на основе истории изменений
  List<BalanceDataPoint> _calculateDailyBalances(
    List<AccountHistoryModel> history,
    DateTime startDate,
    DateTime endDate,
  ) {
    if (history.isEmpty) return [];

    // Сортируем историю по времени
    history.sort((a, b) => a.changeTimestamp.compareTo(b.changeTimestamp));

    final Map<DateTime, double> dailyBalancesMap = {};
    double currentBalance = 0.0;

    // Определяем начальный баланс до startDate, если таковой есть в истории
    // Ищем самую раннюю запись, которая является creation или модификацией
    AccountHistoryModel? initialEntry;
    for (final entry in history) {
      if (entry.changeType == ChangeType.creation ||
          entry.changeType == ChangeType.modification) {
        initialEntry = entry;
        break;
      }
    }

    if (initialEntry != null) {
      currentBalance = double.parse(initialEntry.newState.balance);
    } else {}

    // Проходимся по всем дням в заданном диапазоне
    DateTime currentDate = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    while (currentDate.isBefore(endDate.add(const Duration(days: 1)))) {
      // Ищем последние изменения до или на текущую дату
      double balanceForThisDay = currentBalance;
      for (final entry in history) {
        // Убедимся, что сравниваем только дату без времени
        final entryDate = DateTime(
          entry.changeTimestamp.year,
          entry.changeTimestamp.month,
          entry.changeTimestamp.day,
        );

        if (entryDate.isBefore(currentDate) ||
            entryDate.isAtSameMomentAs(currentDate)) {
          if ((entry.changeType == ChangeType.creation ||
              entry.changeType == ChangeType.modification)) {
            balanceForThisDay = double.parse(entry.newState.balance);
          }
        } else {
          // История дальше текущей даты, прекращаем просмотр
          break;
        }
      }
      dailyBalancesMap[currentDate] = balanceForThisDay;
      currentBalance =
          balanceForThisDay; // Баланс для следующего дня начинается с этого
      currentDate = currentDate.add(const Duration(days: 1));
    }

    // Преобразуем мапу в список BalanceDataPoint
    final List<BalanceDataPoint> result = dailyBalancesMap.entries
        .map((e) => BalanceDataPoint(date: e.key, amount: e.value))
        .toList();
    result.sort((a, b) => a.date.compareTo(b.date)); // Сортировка по дате

    return result;
  }

  // Метод для агрегации данных по месяцам (берем значение последнего дня месяца)
  List<BalanceDataPoint> _aggregateMonthlyData(
    List<BalanceDataPoint> dailyData,
  ) {
    if (dailyData.isEmpty) return [];

    final Map<String, BalanceDataPoint> monthlyDataMap =
        {}; // 'YYYY-MM' -> BalanceDataPoint

    // Сортируем данные по дате, чтобы гарантировать, что последний день будет обработан последним
    dailyData.sort((a, b) => a.date.compareTo(b.date));

    for (final dp in dailyData) {
      final monthKey =
          '${dp.date.year}-${dp.date.month.toString().padLeft(2, '0')}';
      // Всегда перезаписываем, чтобы убедиться, что сохраняется значение самого последнего дня месяца
      // для данного месяца, который находится в dailyData
      monthlyDataMap[monthKey] = dp;
    }

    final List<BalanceDataPoint> result = monthlyDataMap.values.toList();
    result.sort((a, b) => a.date.compareTo(b.date)); // Снова сортируем по дате

    return result;
  }

  void setSelectedChartPeriod(ChartPeriod period) {
    if (state.selectedChartPeriod != period) {
      state = state.copyWith(selectedChartPeriod: period);
      // Если счет уже загружен, перезагружаем данные графика
      if (state.account != null) {
        _fetchBalanceDataForChart(state.account!.id);
      }
    }
  }
}

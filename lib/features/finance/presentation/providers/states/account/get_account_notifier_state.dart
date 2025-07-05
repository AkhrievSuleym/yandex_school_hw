import 'package:yandex_shmr_hw/core/error/failure.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_response_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/balance_data_point.dart';

enum ChartPeriod { daily, monthly }

class AccountPageState {
  final AccountResponseModel? account;
  final bool isLoading;
  final Failure? error;
  final bool isBalanceBlurred;

  // Новые поля для графика
  final List<BalanceDataPoint> chartBalanceData;
  final ChartPeriod selectedChartPeriod;
  final bool isChartLoading;
  final String? chartErrorMessage;

  AccountPageState({
    this.account,
    this.isLoading = false,
    this.error,
    this.isBalanceBlurred = true,
    this.chartBalanceData = const [],
    this.selectedChartPeriod = ChartPeriod.daily,
    this.isChartLoading = false,
    this.chartErrorMessage,
  });

  AccountPageState copyWith({
    AccountResponseModel? account,
    bool? isLoading,
    Failure? error,
    bool? isBalanceBlurred,
    List<BalanceDataPoint>? chartBalanceData,
    ChartPeriod? selectedChartPeriod,
    bool? isChartLoading,
    String? chartErrorMessage,
  }) {
    return AccountPageState(
      account: account ?? this.account,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isBalanceBlurred: isBalanceBlurred ?? this.isBalanceBlurred,
      chartBalanceData: chartBalanceData ?? this.chartBalanceData,
      selectedChartPeriod: selectedChartPeriod ?? this.selectedChartPeriod,
      isChartLoading: isChartLoading ?? this.isChartLoading,
      chartErrorMessage: chartErrorMessage,
    );
  }
}

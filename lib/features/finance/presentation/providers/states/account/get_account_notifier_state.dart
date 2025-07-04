import 'package:yandex_shmr_hw/core/error/failure.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_response_model.dart';

class AccountPageState {
  final AccountResponseModel? account;
  final bool isLoading;
  final Failure? error;
  final bool isBalanceBlurred;

  AccountPageState({
    this.account,
    this.isLoading = false,
    this.error,
    this.isBalanceBlurred = true,
  });

  AccountPageState copyWith({
    AccountResponseModel? account,
    bool? isLoading,
    Failure? error,
    bool? isBalanceBlurred,
  }) {
    return AccountPageState(
      account: account ?? this.account,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isBalanceBlurred: isBalanceBlurred ?? this.isBalanceBlurred,
    );
  }
}

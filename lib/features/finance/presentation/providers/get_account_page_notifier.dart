import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_shmr_hw/features/finance/di/usecase_providers.dart';
import 'package:yandex_shmr_hw/features/finance/domain/usecases/account/get_account_usecase.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/states/get_account_notifier_state.dart';

final accountPageNotifierProvider =
    StateNotifierProvider<AccountPageNotifier, AccountPageState>((ref) {
      final getAccountByIdUseCase = ref.read(getAccountByIdUseCaseProvider);
      return AccountPageNotifier(getAccountByIdUseCase);
    });

class AccountPageNotifier extends StateNotifier<AccountPageState> {
  final GetAccountByIdUseCase _getAccountByIdUseCase;

  AccountPageNotifier(this._getAccountByIdUseCase) : super(AccountPageState()) {
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
}

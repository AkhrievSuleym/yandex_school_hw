import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_update_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/enums/currency.dart';
import 'package:yandex_shmr_hw/features/finance/di/usecase_providers.dart';
import 'package:yandex_shmr_hw/features/finance/domain/usecases/account/get_account_usecase.dart';
import 'package:yandex_shmr_hw/features/finance/domain/usecases/account/update_account_usecase.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/states/account/edit_account_notifier.dart';

final editAccountPageNotifierProvider =
    StateNotifierProvider.family<
      EditAccountPageNotifier,
      EditAccountPageState,
      int
    >((ref, accountId) {
      final getAccountByIdUseCase = ref.read(getAccountByIdUseCaseProvider);
      final updateBankAccountUseCase = ref.read(
        updateBankAccountUseCaseProvider,
      );
      return EditAccountPageNotifier(
        accountId,
        getAccountByIdUseCase,
        updateBankAccountUseCase,
      );
    });

class EditAccountPageNotifier extends StateNotifier<EditAccountPageState> {
  final int _accountId;
  final GetAccountByIdUseCase _getAccountByIdUseCase;
  final UpdateBankAccountUseCase _updateBankAccountUseCase;

  EditAccountPageNotifier(
    this._accountId,
    this._getAccountByIdUseCase,
    this._updateBankAccountUseCase,
  ) : super(EditAccountPageState()) {
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _getAccountByIdUseCase(
      GetAccountByIdParams(accountId: _accountId),
    );
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure),
      (accountResponse) {
        state = state.copyWith(
          isLoading: false,
          originalAccount: AccountModel(
            // Сохраняем как AccountModel, а не ResponseModel
            id: accountResponse.id,
            userId: 1, // Моковый userId
            name: accountResponse.name,
            balance: accountResponse.balance,
            currency: accountResponse.currency,
            createdAt: accountResponse.createdAt,
            updatedAt: accountResponse.updatedAt,
          ),
          name: accountResponse.name,
          balance: accountResponse.balance,
          currency: accountResponse.currency,
        );
      },
    );
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateBalance(String balance) {
    state = state.copyWith(balance: balance);
  }

  void updateCurrency(Currency currency) {
    state = state.copyWith(currency: currency);
  }

  Future<bool> saveAccount() async {
    state = state.copyWith(isSaving: true, error: null, saveSuccess: false);

    final updatedRequest = AccountUpdateModel(
      name: state.name,
      balance: state.balance,
      currency: state.currency,
    );

    final params = UpdateBankAccountParams(
      accountId: _accountId,
      requestUpdatedAccount: updatedRequest,
    );

    final result = await _updateBankAccountUseCase(params);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isSaving: false,
          error: failure,
          saveSuccess: false,
        );
        return false;
      },
      (account) {
        state = state.copyWith(
          isSaving: false,
          originalAccount:
              account, // Обновляем оригинальный счет после сохранения
          saveSuccess: true,
        );
        return true;
      },
    );
  }
}

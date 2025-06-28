import 'package:yandex_shmr_hw/core/error/failure.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/enums/currency.dart';

class EditAccountPageState {
  final AccountModel? originalAccount;
  final String name;
  final String balance;
  final Currency currency;
  final bool isLoading;
  final Failure? error;
  final bool isSaving; // Для индикации сохранения
  final bool saveSuccess; // Для индикации успешного сохранения

  EditAccountPageState({
    this.originalAccount,
    this.name = '',
    this.balance = '0.00',
    this.currency = Currency.rub,
    this.isLoading = false,
    this.error,
    this.isSaving = false,
    this.saveSuccess = false,
  });

  EditAccountPageState copyWith({
    AccountModel? originalAccount,
    String? name,
    String? balance,
    Currency? currency,
    bool? isLoading,
    Failure? error,
    bool? isSaving,
    bool? saveSuccess,
  }) {
    return EditAccountPageState(
      originalAccount: originalAccount ?? this.originalAccount,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSaving: isSaving ?? this.isSaving,
      saveSuccess: saveSuccess ?? this.saveSuccess,
    );
  }
}

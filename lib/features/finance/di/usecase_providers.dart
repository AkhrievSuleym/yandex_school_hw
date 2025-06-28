import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_shmr_hw/features/finance/di/bank_account_providers.dart';
import 'package:yandex_shmr_hw/features/finance/di/transactions_providers.dart';
import 'package:yandex_shmr_hw/features/finance/domain/usecases/account/get_account_usecase.dart';
import 'package:yandex_shmr_hw/features/finance/domain/usecases/account/update_account_usecase.dart';
import 'package:yandex_shmr_hw/features/finance/domain/usecases/categories/get_all_categories_usecase.dart';
import 'package:yandex_shmr_hw/features/finance/domain/usecases/transactions/get_transactions_usecase.dart';

final getTransactionsUseCaseProvider = Provider<GetTransactionsUseCase>(
  (ref) => GetTransactionsUseCase(ref.read(transactionsRepositoryProvider)),
);

final getAccountByIdUseCaseProvider = Provider<GetAccountByIdUseCase>((ref) {
  final repository = ref.read(bankAccountRepositoryProvider);
  return GetAccountByIdUseCase(repository);
});

final getAllCategoriesUseCaseProvider = Provider<GetAllCategoriesUseCase>(
  (ref) => GetAllCategoriesUseCase(
    ref.read(categoryRepositoryProvider), // Usecase зависит от репозитория
  ),
);

final updateBankAccountUseCaseProvider = Provider<UpdateBankAccountUseCase>((
  ref,
) {
  final repository = ref.read(bankAccountRepositoryProvider);
  return UpdateBankAccountUseCase(repository);
});

import 'package:fpdart/fpdart.dart';
import 'package:yandex_shmr_hw/core/error/failure.dart';
import 'package:yandex_shmr_hw/core/usecases/usecase.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_update_model.dart';
import 'package:yandex_shmr_hw/features/finance/domain/repository/bank_account_repository.dart';

class UpdateBankAccountUseCase
    implements UseCase<AccountModel, UpdateBankAccountParams> {
  final BankAccountRepository repository;

  UpdateBankAccountUseCase(this.repository);

  @override
  Future<Either<Failure, AccountModel>> call(
    UpdateBankAccountParams params,
  ) async {
    return await repository.updateBankAccount(
      params.accountId,
      params.requestUpdatedAccount,
    );
  }
}

class UpdateBankAccountParams {
  final int accountId;
  final AccountUpdateModel requestUpdatedAccount;

  UpdateBankAccountParams({
    required this.accountId,
    required this.requestUpdatedAccount,
  });
}

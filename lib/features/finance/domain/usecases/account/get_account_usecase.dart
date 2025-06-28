import 'package:fpdart/fpdart.dart';
import 'package:yandex_shmr_hw/core/error/failure.dart';
import 'package:yandex_shmr_hw/core/usecases/usecase.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_response_model.dart';
import 'package:yandex_shmr_hw/features/finance/domain/repository/bank_account_repository.dart';

class GetAccountByIdUseCase
    implements UseCase<AccountResponseModel, GetAccountByIdParams> {
  final BankAccountRepository repository;

  GetAccountByIdUseCase(this.repository);

  @override
  Future<Either<Failure, AccountResponseModel>> call(
    GetAccountByIdParams params,
  ) async {
    return await repository.getBankAccountById(params.accountId);
  }
}

class GetAccountByIdParams {
  final int accountId;

  GetAccountByIdParams({required this.accountId});
}

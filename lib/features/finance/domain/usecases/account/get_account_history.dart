import 'package:fpdart/fpdart.dart';
import 'package:yandex_shmr_hw/core/error/failure.dart';
import 'package:yandex_shmr_hw/core/usecases/usecase.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_history_response_model.dart'; // Изменил на AccountHistoryResponseModel
import 'package:yandex_shmr_hw/features/finance/domain/repository/bank_account_repository.dart';

class GetAccountHistoryUseCase
    implements UseCase<AccountHistoryResponseModel, GetAccountHistoryParams> {
  final BankAccountRepository repository;

  GetAccountHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, AccountHistoryResponseModel>> call(
    GetAccountHistoryParams params,
  ) async {
    return await repository.getAccountHistory(params.accountId);
  }
}

class GetAccountHistoryParams {
  final int accountId;

  GetAccountHistoryParams({required this.accountId});
}

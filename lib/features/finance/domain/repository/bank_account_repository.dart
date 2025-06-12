import 'package:fpdart/fpdart.dart';
import 'package:yandex_shmr_hw/core/error/failure.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_history_response_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_response_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_update_model.dart';

abstract interface class BankAccountRepository {
  Future<Either<Failure, List<AccountModel>>> getAllBankAccounts();
  Future<Either<Failure, AccountResponseModel>> getBankAccountById(String id);
  Future<Either<Failure, AccountModel>> updateBankAccount(
    String accountId,
    AccountUpdateModel request,
  );
  Future<Either<Failure, AccountHistoryResponseModel>> getAccountHistory(
    String accountId,
  );
}

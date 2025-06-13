import 'package:fpdart/fpdart.dart';
import 'package:yandex_shmr_hw/core/error/failure.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_create_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_history_response_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_response_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_update_model.dart';

abstract interface class BankAccountRepository {
  Future<Either<Failure, List<AccountModel>>> getAllBankAccounts();
  Future<Either<Failure, AccountModel>> addBankAccount(
    AccountCreateModel requestNewAccount,
  );
  Future<Either<Failure, AccountResponseModel>> getBankAccountById(int id);
  Future<Either<Failure, AccountModel>> updateBankAccount(
    int accountId,
    AccountUpdateModel requestUpdatedAccount,
  );
  Future<Either<Failure, AccountHistoryResponseModel>> getAccountHistory(
    int accountId,
  );
}

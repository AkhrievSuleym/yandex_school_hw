import 'package:fpdart/fpdart.dart';
import 'package:yandex_shmr_hw/core/error/failure.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_request_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_response_model.dart';

abstract interface class TransactionRepository {
  Future<Either<Failure, TransactionModel>> addTransaction(
    TransactionRequestModel transaction,
  );
  Future<Either<Failure, TransactionResponseModel>> getTransactionById({
    required int transactionId,
  });
  Future<Either<Failure, TransactionResponseModel>> updateTransaction(
    int transactionId,
    TransactionRequestModel transaction,
  );
  Future<Either<Failure, void>> deleteTransaction(int transactionId);
  Future<Either<Failure, List<TransactionResponseModel>>>
  getAccountTransactions({
    required int accountId,
    DateTime? startDate,
    DateTime? endDate,
  });
}

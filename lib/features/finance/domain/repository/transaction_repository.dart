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
    String transactionId,
  });
  Future<Either<Failure, TransactionResponseModel>> updateTransaction(
    String transactionId,
    TransactionRequestModel transaction,
  );
  Future<Either<Failure, void>> deleteTransaction(String transactionId);
  Future<Either<Failure, List<TransactionResponseModel>>>
  getAccountTransactions({
    String accountId,
    DateTime? startDate,
    DateTime? endDate,
  });
}

import 'package:fpdart/fpdart.dart';
import 'package:yandex_shmr_hw/core/error/failure.dart';
import 'package:yandex_shmr_hw/core/usecases/usecase.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_request_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_response_model.dart';
import 'package:yandex_shmr_hw/features/finance/domain/repository/transaction_repository.dart';

class UpdateTransactionUseCase
    implements UseCase<TransactionResponseModel, UpdateTransactionParams> {
  final TransactionRepository transactionsRepository;

  UpdateTransactionUseCase(this.transactionsRepository);

  @override
  Future<Either<Failure, TransactionResponseModel>> call(
    UpdateTransactionParams params,
  ) async {
    return await transactionsRepository.updateTransaction(
      params.transactionId,
      params.transaction,
    );
  }
}

class UpdateTransactionParams {
  final int transactionId;
  final TransactionRequestModel transaction;

  UpdateTransactionParams({
    required this.transactionId,
    required this.transaction,
  });
}

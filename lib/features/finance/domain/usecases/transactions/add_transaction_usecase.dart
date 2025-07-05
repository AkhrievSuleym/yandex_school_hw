import 'package:fpdart/fpdart.dart';
import 'package:yandex_shmr_hw/core/error/failure.dart';
import 'package:yandex_shmr_hw/core/usecases/usecase.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_request_model.dart';
import 'package:yandex_shmr_hw/features/finance/domain/repository/transaction_repository.dart';

class AddTransactionUseCase
    implements UseCase<TransactionModel, AddTransactionParams> {
  final TransactionRepository transactionsRepository;

  AddTransactionUseCase(this.transactionsRepository);

  @override
  Future<Either<Failure, TransactionModel>> call(
    AddTransactionParams params,
  ) async {
    return await transactionsRepository.addTransaction(params.transaction);
  }
}

class AddTransactionParams {
  final TransactionRequestModel transaction;

  AddTransactionParams({required this.transaction});
}

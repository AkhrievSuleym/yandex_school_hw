import 'package:fpdart/fpdart.dart';
import 'package:yandex_shmr_hw/core/error/failure.dart';
import 'package:yandex_shmr_hw/core/usecases/usecase.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_response_model.dart';
import 'package:yandex_shmr_hw/features/finance/domain/repository/transaction_repository.dart';

class GetTransactionsUseCase
    implements UseCase<List<TransactionResponseModel>, GetTransactionsParams> {
  final TransactionRepository transactionsRepository;

  GetTransactionsUseCase(this.transactionsRepository);

  @override
  Future<Either<Failure, List<TransactionResponseModel>>> call(
    GetTransactionsParams params,
  ) async {
    return await transactionsRepository.getAccountTransactions(
      accountId: params.accountId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetTransactionsParams {
  final int accountId;
  final DateTime? startDate;
  final DateTime? endDate;

  GetTransactionsParams({
    required this.accountId,
    this.startDate,
    this.endDate,
  });
}

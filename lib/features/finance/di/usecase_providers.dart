import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_shmr_hw/features/finance/di/repository_providers.dart';
import 'package:yandex_shmr_hw/features/finance/domain/usecases/transactions/get_transactions_usecase.dart';

final getTransactionsUseCaseProvider = Provider<GetTransactionsUseCase>(
  (ref) => GetTransactionsUseCase(ref.read(transactionsRepositoryProvider)),
);

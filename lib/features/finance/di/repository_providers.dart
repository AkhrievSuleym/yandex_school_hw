import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_shmr_hw/features/finance/data/repositories/transaction_repository_impl.dart';
import 'package:yandex_shmr_hw/features/finance/domain/repository/transaction_repository.dart';

final transactionsRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepositoryImpl(),
);

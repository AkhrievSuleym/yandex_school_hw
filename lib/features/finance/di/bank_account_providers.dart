import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_shmr_hw/core/network/api_client.dart';
import 'package:yandex_shmr_hw/core/network/connectivity_service.dart';
import 'package:yandex_shmr_hw/features/finance/data/local_datasource/account_local_datasource.dart';
import 'package:yandex_shmr_hw/features/finance/data/remote_datasource/account_remote_ds.dart';
import 'package:yandex_shmr_hw/features/finance/data/repositories/bank_account_repository_impl.dart';
import 'package:yandex_shmr_hw/features/finance/data/repositories/category_repository_impl.dart';
import 'package:yandex_shmr_hw/features/finance/domain/repository/bank_account_repository.dart';
import 'package:yandex_shmr_hw/features/finance/domain/repository/category_repository.dart';
import 'package:yandex_shmr_hw/main.dart';

final bankAccountRepositoryProvider = Provider<BankAccountRepository>((ref) {
  return BankAccountRepositoryImpl(
    AccountLocalDatasource(database),
    AccountRemoteDatasource(ApiClient()),
    ConnectivityService(),
  );
});

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) =>
      CategoryRepositoryImpl(), // Здесь создается экземпляр реализации репозитория
);

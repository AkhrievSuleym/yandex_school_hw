import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_shmr_hw/core/network/api_client.dart';
import 'package:yandex_shmr_hw/core/network/connectivity_service.dart';
import 'package:yandex_shmr_hw/core/sync/sync_service.dart';
import 'package:yandex_shmr_hw/features/finance/data/local_datasource/account_local_datasource.dart';
import 'package:yandex_shmr_hw/features/finance/data/local_datasource/categories_local_datasource.dart';
import 'package:yandex_shmr_hw/features/finance/data/local_datasource/operation_local_datasource.dart';
import 'package:yandex_shmr_hw/features/finance/data/local_datasource/transaction_local_datasource.dart';
import 'package:yandex_shmr_hw/features/finance/data/remote_datasource/account_remote_ds.dart';
import 'package:yandex_shmr_hw/features/finance/data/remote_datasource/category_remote_ds.dart';
import 'package:yandex_shmr_hw/features/finance/data/remote_datasource/transaction_remote_ds.dart';
import 'package:yandex_shmr_hw/features/finance/data/repositories/bank_account_repository_impl.dart';
import 'package:yandex_shmr_hw/features/finance/data/repositories/category_repository_impl.dart';
import 'package:yandex_shmr_hw/features/finance/data/repositories/transaction_repository_impl.dart';
import 'package:yandex_shmr_hw/features/finance/domain/repository/bank_account_repository.dart';
import 'package:yandex_shmr_hw/features/finance/domain/repository/category_repository.dart';
import 'package:yandex_shmr_hw/features/finance/domain/repository/transaction_repository.dart';
import 'package:yandex_shmr_hw/main.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Провайдер для ConnectivityService
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

// --- Провайдеры локальных источников данных ---
final accountLocalDatasourceProvider = Provider<AccountLocalDatasource>((ref) {
  return AccountLocalDatasource(database);
});

final transactionLocalDatasourceProvider = Provider<TransactionLocalDatasource>(
  (ref) {
    return TransactionLocalDatasource(database);
  },
);

final categoryLocalDatasourceProvider = Provider<CategoriesLocalDatasource>((
  ref,
) {
  return CategoriesLocalDatasource(database);
});

final operationLocalDatasourceProvider = Provider<OperationLocalDatasource>((
  ref,
) {
  return OperationLocalDatasource(database);
});

// --- Провайдеры удаленных источников данных ---
final accountRemoteDatasourceProvider = Provider<AccountRemoteDatasource>((
  ref,
) {
  return AccountRemoteDatasource(ref.read(apiClientProvider));
});

final transactionRemoteDatasourceProvider =
    Provider<TransactionRemoteDatasource>((ref) {
      return TransactionRemoteDatasource(ref.read(apiClientProvider));
    });

final categoryRemoteDatasourceProvider = Provider<CategoryRemoteDatasource>((
  ref,
) {
  return CategoryRemoteDatasource(ref.read(apiClientProvider));
});

// --- Провайдер для SyncService ---
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    ref.read(operationLocalDatasourceProvider),
    ref.read(connectivityServiceProvider),
    ref.read(accountLocalDatasourceProvider),
    ref.read(accountRemoteDatasourceProvider),
    ref.read(transactionLocalDatasourceProvider),
    ref.read(transactionRemoteDatasourceProvider),
  );
});

// --- Провайдеры репозиториев ---
final bankAccountRepositoryProvider = Provider<BankAccountRepository>((ref) {
  return BankAccountRepositoryImpl(
    ref.read(accountLocalDatasourceProvider),
    ref.read(accountRemoteDatasourceProvider),
    ref.read(operationLocalDatasourceProvider),
    ref.read(connectivityServiceProvider),
    ref.read(syncServiceProvider), // Инжектируем SyncService
  );
});

final transactionsRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(
    ref.read(transactionLocalDatasourceProvider),
    ref.read(transactionRemoteDatasourceProvider),
    ref.read(operationLocalDatasourceProvider),
    ref.read(connectivityServiceProvider),
    ref.read(syncServiceProvider),
    ref.read(accountRemoteDatasourceProvider), // Инжектируем SyncService
  );
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(
    ref.read(categoryLocalDatasourceProvider),
    ref.read(categoryRemoteDatasourceProvider),
    ref.read(operationLocalDatasourceProvider),
    ref.read(connectivityServiceProvider),
    ref.read(syncServiceProvider), // Инжектируем SyncService
  );
});

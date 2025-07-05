import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_request_model.dart';
import 'package:yandex_shmr_hw/features/finance/di/usecase_providers.dart';
import 'package:yandex_shmr_hw/features/finance/domain/usecases/transactions/add_transaction_usecase.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/states/transactions/add_transaction_state.dart';

final addTransactionPageNotifierProvider =
    StateNotifierProvider<AddTransactionPageNotifier, AddTransactionPageState>((
      ref,
    ) {
      final addTransactionUseCase = ref.read(addTransactionUseCaseProvider);
      return AddTransactionPageNotifier(addTransactionUseCase);
    });

class AddTransactionPageNotifier
    extends StateNotifier<AddTransactionPageState> {
  final AddTransactionUseCase _addTransactionUseCase;

  AddTransactionPageNotifier(this._addTransactionUseCase)
    : super(
        AddTransactionPageState(
          id: 0,
          accountId: 0,
          categoryId: 0,
          amount: '',
          transactionDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

  Future<void> addTransaction({
    required TransactionRequestModel transaction,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    ); // Устанавливаем состояние загрузки

    final params = AddTransactionParams(transaction: transaction);

    final result = await _addTransactionUseCase(params);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ), // Обработка ошибки
      (addedTransaction) => state = state.copyWith(
        id: addedTransaction.id,
        accountId: addedTransaction.accountId,
        categoryId: addedTransaction.categoryId,
        amount: addedTransaction.amount,
        transactionDate: addedTransaction.transactionDate,
        comment: addedTransaction.comment,
        createdAt: addedTransaction.createdAt,
        updatedAt: addedTransaction.updatedAt,
        isLoading: false,
        error: null,
        isSuccess: true,
      ),
    );
  }
}

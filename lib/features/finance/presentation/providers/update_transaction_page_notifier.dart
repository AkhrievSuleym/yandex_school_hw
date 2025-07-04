import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_request_model.dart';
import 'package:yandex_shmr_hw/features/finance/di/usecase_providers.dart';
import 'package:yandex_shmr_hw/features/finance/domain/usecases/transactions/update_transaction_usecase.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/states/transactions/update_transaction_page_state.dart';

final updateTransactionPageNotifierProvider =
    StateNotifierProvider<
      UpdateTransactionPageNotifier,
      UpdateTransactionPageState
    >((ref) {
      final updateTransactionUseCase = ref.read(
        updateTransactionUseCaseProvider,
      );
      return UpdateTransactionPageNotifier(updateTransactionUseCase);
    });

class UpdateTransactionPageNotifier
    extends StateNotifier<UpdateTransactionPageState> {
  final UpdateTransactionUseCase _updateTransactionUseCase;

  UpdateTransactionPageNotifier(this._updateTransactionUseCase)
    : super(UpdateTransactionPageState());

  Future<void> updateTransaction({
    required int transactionId,
    required TransactionRequestModel transaction,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    ); // Устанавливаем состояние загрузки

    final params = UpdateTransactionParams(
      transactionId: transactionId,
      transaction: transaction,
    );

    final result = await _updateTransactionUseCase(params); // Вызываем Use Case

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure,
      ), // Обработка ошибки
      (updatedTransaction) => state = state.copyWith(
        transaction: updatedTransaction,
        isLoading: false,
        error: null,
        isSuccess: true,
      ), // Успешное обновление
    );
  }
}

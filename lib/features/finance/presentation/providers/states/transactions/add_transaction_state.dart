import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_request_model.dart';
import 'package:yandex_shmr_hw/features/finance/di/usecase_providers.dart';
import 'package:yandex_shmr_hw/features/finance/domain/usecases/transactions/add_transaction_usecase.dart';

class AddTransactionPageState {
  final int id;
  final int accountId;
  final int categoryId;
  final String amount;
  final DateTime transactionDate;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  AddTransactionPageState({
    required this.id,
    required this.accountId,
    required this.categoryId,
    required this.amount,
    required this.transactionDate,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  AddTransactionPageState copyWith({
    int? id,
    int? accountId,
    int? categoryId,
    String? amount,
    DateTime? transactionDate,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return AddTransactionPageState(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      transactionDate: transactionDate ?? this.transactionDate,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_request_model.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/get_account_page_notifier.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/transactions_page_notifier.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/update_transaction_page_notifier.dart';

class UpdateTransactionPage extends ConsumerStatefulWidget {
  final int transactionId;
  final bool isIncome;

  const UpdateTransactionPage({
    super.key,
    required this.transactionId,
    required this.isIncome,
  });

  @override
  ConsumerState<UpdateTransactionPage> createState() =>
      _UpdateTransactionPageState();
}

class _UpdateTransactionPageState extends ConsumerState<UpdateTransactionPage> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final transactionsState = ref.read(transactionsPageNotifierProvider);
      final accountState = ref.read(accountPageNotifierProvider);
      final transaction =
          transactionsState.transactions.length > widget.transactionId
          ? transactionsState.transactions[widget.transactionId]
          : null;

      if (transaction != null) {
        final notifier = ref.read(
          updateTransactionPageNotifierProvider.notifier,
        );
        notifier.updateTransaction(
          transactionId: widget.transactionId,
          transaction: TransactionRequestModel(
            accountId: accountState.account?.id ?? 0,
            categoryId: transaction.category.id,
            amount: transaction.amount,
            transactionDate: transaction.transactionDate,
            comment: transaction.comment,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(updateTransactionPageNotifierProvider);
    final notifier = ref.read(updateTransactionPageNotifierProvider.notifier);
    final accountState = ref.watch(accountPageNotifierProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Транзакция"),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: theme.iconTheme.color),
            iconSize: 30,
            onPressed: () {},
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.cancel_outlined, color: theme.iconTheme.color),
          iconSize: 30,
          onPressed: () {
            context.go("/${widget.isIncome ? "income" : "expenses"}");
          },
        ),
        actionsPadding: const EdgeInsets.only(right: 5.0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (accountState.account != null)
              DropdownButtonFormField<int>(
                value: accountState.account!.id,
                items: [
                  DropdownMenuItem(
                    value: accountState.account!.id,
                    child: Text(accountState.account!.name),
                  ),
                ],
                onChanged: (_) {},
                decoration: const InputDecoration(labelText: 'Счет'),
              )
            else if (accountState.isLoading)
              const CircularProgressIndicator()
            else if (accountState.error != null)
              const Text('Ошибка загрузки счета'),
            TextFormField(
              initialValue: state.transaction?.category.id.toString() ?? '',
              decoration: const InputDecoration(labelText: 'Категория'),
              onChanged: (value) {
                notifier.updateTransaction(
                  transactionId: widget.transactionId,
                  transaction: TransactionRequestModel(
                    accountId: accountState.account?.id ?? 0,
                    categoryId: int.tryParse(value) ?? 0,
                    amount: state.transaction?.amount ?? '',
                    transactionDate:
                        state.transaction?.transactionDate ?? DateTime.now(),
                  ),
                );
              },
            ),
            TextFormField(
              initialValue: state.transaction?.amount ?? '',
              decoration: const InputDecoration(labelText: 'Сумма'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                FilteringTextInputFormatter.allow(RegExp(r'[\,\.]')),
                _DecimalTextInputFormatter(),
              ],
              onChanged: (value) {
                notifier.updateTransaction(
                  transactionId: widget.transactionId,
                  transaction: TransactionRequestModel(
                    accountId: accountState.account!.id ?? 0,
                    categoryId:
                        int.tryParse(
                          state.transaction?.category.id.toString() ?? '',
                        ) ??
                        0,
                    amount: value,
                    transactionDate:
                        state.transaction?.transactionDate ?? DateTime.now(),
                  ),
                );
              },
            ),
            TextFormField(
              initialValue: state.transaction?.transactionDate != null
                  ? DateFormat(
                      'dd.MM.yyyy',
                    ).format(state.transaction!.transactionDate)
                  : null,
              decoration: const InputDecoration(labelText: 'Дата'),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate:
                      state.transaction?.transactionDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  notifier.updateTransaction(
                    transactionId: widget.transactionId,
                    transaction: TransactionRequestModel(
                      accountId: accountState.account?.id ?? 0,
                      categoryId:
                          int.tryParse(
                            state.transaction?.category.id.toString() ?? '',
                          ) ??
                          0,
                      amount: state.transaction?.amount ?? '',
                      transactionDate: picked,
                    ),
                  );
                }
              },
            ),
            TextFormField(
              initialValue: state.transaction?.comment ?? 'Комментарий',
              decoration: const InputDecoration(labelText: 'Время'),
              onChanged: (value) {
                notifier.updateTransaction(
                  transactionId: widget.transactionId,
                  transaction: TransactionRequestModel(
                    accountId: accountState.account?.id ?? 0,
                    categoryId:
                        int.tryParse(
                          state.transaction?.category.id.toString() ?? '',
                        ) ??
                        0,
                    amount: state.transaction?.amount ?? '',
                    transactionDate:
                        state.transaction?.transactionDate ?? DateTime.now(),
                    comment: value.isEmpty ? null : value,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: state.isLoading
                  ? null
                  : () async {
                      if (state.transaction?.category.id == null ||
                          state.transaction?.amount == null ||
                          state.transaction?.amount.isEmpty == true ||
                          state.transaction?.transactionDate == null) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Ошибка'),
                            content: const Text(
                              'Пожалуйста, заполните все поля',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }
                      await notifier.updateTransaction(
                        transactionId: widget.transactionId,
                        transaction: TransactionRequestModel(
                          accountId: accountState.account!.id,
                          categoryId: int.parse(
                            state.transaction!.category.id.toString(),
                          ),
                          amount: state.transaction!.amount,
                          transactionDate: state.transaction!.transactionDate,
                          comment: state.transaction!.comment,
                        ),
                      );
                      if (state.isSuccess)
                        context.go(
                          "/${widget.isIncome ? "income" : "expenses"}",
                        );
                    },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Удалить расход'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final decimalSeparator = NumberFormat().symbols.DECIMAL_SEP;
    final digitsOnly = RegExp(r'^[0-9]*\.?[0-9]{0,2}$');
    String newText = newValue.text;

    if (!digitsOnly.hasMatch(newText)) return oldValue;

    final parts = newText.split(decimalSeparator);
    if (parts.length > 2) return oldValue;

    if (parts.length == 2 && parts[1].length > 2) return oldValue;

    return newValue;
  }
}

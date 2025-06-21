import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/transactions_screen_notifier.dart';

class TransactionsPage extends ConsumerWidget {
  final bool isIncome;

  const TransactionsPage({super.key, this.isIncome = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenState = ref.watch(transactionsScreenNotifierProvider);

    final filteredTransactions = screenState.transactions.where((transaction) {
      if (isIncome == true) {
        return transaction.category.isIncome;
      } else {
        return !transaction.category.isIncome;
      }
    }).toList();

    final double displayTotal = filteredTransactions.fold(
      0.0,
      (sum, tr) => sum + double.parse(tr.amount),
    );

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ), // Внутренний отступ
          decoration: BoxDecoration(color: const Color(0xFFD4FAE6)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Всего',
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Text(
                '${displayTotal.toStringAsFixed(2)} ₽',
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: screenState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : screenState.error != null
              ? Center(child: Text('Ошибка: ${screenState.error!.message}'))
              : ListView.builder(
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = filteredTransactions[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        leading: Text(
                          transaction.category.emoji,
                          style: const TextStyle(
                            fontSize: 24,
                          ), // Увеличим размер для эмодзи
                        ),
                        title: Text(transaction.category.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${double.parse(transaction.amount).toStringAsFixed(2)} ₽',
                              style: TextStyle(
                                fontSize: 19,
                                color: transaction.category.isIncome
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 10),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        onTap: () {
                          // TODO: Навигация для редактирования/деталей операции
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

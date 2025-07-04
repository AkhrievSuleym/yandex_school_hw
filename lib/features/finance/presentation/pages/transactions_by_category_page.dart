import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_response_model.dart';

class TransactionsByCategoryPage extends StatelessWidget {
  final List<TransactionResponseModel> transactions;

  const TransactionsByCategoryPage({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Транзакции по категории',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: transactions.isEmpty
          ? const Center(child: Text('Нет транзакций в этой категории.'))
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    leading: Text(
                      transaction.category.emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: Text(
                      transaction.comment ?? transaction.category.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat(
                        'd MMMM yyyy',
                        'ru',
                      ).format(transaction.transactionDate),
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    trailing: Text(
                      '${double.parse(transaction.amount).toStringAsFixed(2)} ₽',
                      style: TextStyle(
                        color: transaction.category.isIncome
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
                    onTap: () {
                      // TODO: Обработка нажатия на отдельную транзакцию, если нужно
                    },
                  ),
                );
              },
            ),
    );
  }
}

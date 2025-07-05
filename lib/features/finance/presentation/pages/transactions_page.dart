import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yandex_shmr_hw/core/theme/app_theme.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/transactions_page_notifier.dart';

class TransactionsPage extends ConsumerWidget {
  final bool isIncome;

  const TransactionsPage({super.key, this.isIncome = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenState = ref.watch(transactionsPageNotifierProvider);
    final theme = Theme.of(context);

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

    final String title;
    final String path;

    if (isIncome) {
      title = "Доходы сегодня";
      path = "income";
    } else {
      title = "Расходы сегодня";
      path = "expenses";
    } //AppLocalizations.of(context)!.titleExpenses;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: theme.iconTheme.color),
            iconSize: 30,
            onPressed: () {
              context.go('/$path/history');
            },
          ),
        ],
        actionsPadding: const EdgeInsets.only(right: 5.0),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: theme.cardColor,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
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
                            style: const TextStyle(fontSize: 24),
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
                            context.go(
                              '/$path/update/${filteredTransactions[index].id}',
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go("/$path/add");
        },
        backgroundColor:
            Theme.of(
              context,
            ).elevatedButtonTheme.style?.backgroundColor?.resolve({}) ??
            AppColors.buttonLight,
        child: const Icon(Icons.add),
      ),
    );
  }
}

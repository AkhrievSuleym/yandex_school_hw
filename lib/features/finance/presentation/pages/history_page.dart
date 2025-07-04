import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
// import 'package:yandex_shmr_hw/core/theme/app_theme.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/enums/sort_by.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/history_page_notifier.dart';

class HistoryPage extends ConsumerStatefulWidget {
  final bool isIncome;
  const HistoryPage({super.key, required this.isIncome});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  late final HistoryPageNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = ref.read(historyPageNotifierProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifier.init(widget.isIncome);
      _notifier.loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pageState = ref.watch(historyPageNotifierProvider);

    final String path = widget.isIncome ? "income" : "expenses";

    final double displayTotal = pageState.transactions.fold(
      0.0,
      (sum, tr) => sum + double.parse(tr.amount),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("Моя история"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/analysis.svg',
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () {
                context.go(
                  '/${widget.isIncome ? "income" : "expenses"}/history/analysis',
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              children: [
                _buildDateRow(
                  context,
                  // AppLocalizations.of(context)!.historyStartDate,
                  "Начало",
                  pageState.startDate,
                  (date) => _notifier.setStartDate(date),
                ),
                const SizedBox(height: 1),
                _buildDateRow(
                  context,
                  // AppLocalizations.of(context)!.historyEndDate,
                  "Конец",
                  pageState.endDate,
                  (date) => _notifier.setEndDate(date),
                ),
                const SizedBox(height: 1),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(color: const Color(0xFFD4FAE6)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        // AppLocalizations.of(context)!.historyTotal,
                        "Сумма",
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      Text(
                        '${displayTotal.toStringAsFixed(2)} ₽',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      _showSortOptionDialog(context, pageState.sortBy);
                    },
                    icon: const Icon(Icons.sort),
                    label: Text(
                      "Сортировка",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: pageState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : pageState.error != null
                ? Center(child: Text('Ошибка: ${pageState.error!.message}'))
                : pageState.transactions.isEmpty
                ? const Center(child: Text('Операций за выбранный период нет.'))
                : ListView.builder(
                    itemCount: pageState.transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = pageState.transactions[index];
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
                          subtitle: transaction.comment != null
                              ? Text(
                                  transaction.category.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.color,
                                  ),
                                )
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    '${double.parse(transaction.amount).toStringAsFixed(2)} ₽',
                                    style: TextStyle(
                                      color: transaction.category.isIncome
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19,
                                    ),
                                  ),
                                  Text(
                                    DateFormat(
                                      'd MMMM yyyy',
                                      'ru',
                                    ).format(transaction.createdAt),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.color,
                                    ),
                                  ),
                                ],
                              ),

                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
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
      ),
    );
  }

  Widget _buildDateRow(
    BuildContext context,
    String label,
    DateTime date,
    Function(DateTime) onDateSelected,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16.0, right: 5.0, top: 2.0),
      decoration: BoxDecoration(color: const Color(0xFFD4FAE6)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          TextButton(
            onPressed: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null && pickedDate != date) {
                onDateSelected(pickedDate);
              }
            },
            child: Text(
              DateFormat('d MMMM yyyy', 'ru').format(date),
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortOptionDialog(BuildContext context, SortBy currentSortBy) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Сортировка'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("По дате"),
                trailing: currentSortBy == SortBy.date
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  _notifier.setSortBy(SortBy.date);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text("По сумме"),
                trailing: currentSortBy == SortBy.amount
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  _notifier.setSortBy(SortBy.amount);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/ananlysis_page_notifier.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/states/transactions/analysis_page_state.dart';
import 'package:pie_chart_feature/pie_chart_feature.dart';

class AnalysisPage extends ConsumerStatefulWidget {
  final bool? isIncome;

  const AnalysisPage({super.key, required this.isIncome});

  @override
  ConsumerState<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends ConsumerState<AnalysisPage> {
  late final AnalysisPageNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = ref.read(
      analysisPageNotifierProvider(widget.isIncome).notifier,
    );
  }

  List<PieChartSectionDataConfig> _generateChartData(
    AnalysisPageState pageState,
  ) {
    if (pageState.groupedTransactions.isEmpty) {
      return [];
    }

    final totalAmount = pageState.groupedTransactions.fold(
      0.0,
      (sum, item) => sum + item.totalAmount,
    );
    if (totalAmount == 0) {
      return []; // Избегаем деления на ноль
    }

    // Список цветов для секций графика
    final List<Color> chartColors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.yellow,
      Colors.teal,
      Colors.cyan,
    ];

    return pageState.groupedTransactions.asMap().entries.map((entry) {
      final index = entry.key;
      final groupedItem = entry.value;
      final percentage = (groupedItem.totalAmount / totalAmount * 100);
      final color =
          chartColors[index %
              chartColors.length]; // Циклическое использование цветов

      return PieChartSectionDataConfig(
        value: groupedItem.totalAmount,
        title:
            '${percentage.toStringAsFixed(0)}%', // Процент без десятичных знаков
        color: color,
        tooltipLabel: groupedItem.category.name,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final pageState = ref.watch(analysisPageNotifierProvider(widget.isIncome));
    final theme = Theme.of(context);

    final double displayTotal = pageState.groupedTransactions.fold(
      0.0,
      (sum, groupedTr) => sum + groupedTr.totalAmount,
    );

    final List<PieChartSectionDataConfig> chartData = _generateChartData(
      pageState,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Анализ",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              children: [
                _buildDateRow(
                  context,
                  "Период: начало",
                  pageState.startDate,
                  (date) => _notifier.setStartDate(date),
                ),
                const SizedBox(height: 1),
                _buildDateRow(
                  context,
                  "Период: конец",
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
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Сумма",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      Text(
                        '${displayTotal.toStringAsFixed(2)} ₽',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 300, // Высота для графика
                  child: Center(
                    child: pageState.isLoading
                        ? const CircularProgressIndicator()
                        : pageState.error != null
                        ? Text('Ошибка: ${pageState.error!.message}')
                        : AnimatedPieChart(
                            data: chartData,
                            radius: 80, // Радиус графика
                            centerValueText:
                                'Всего\n${displayTotal.toStringAsFixed(2)} ₽',
                            centerTextStyle: theme.textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: pageState.groupedTransactions.isEmpty
                ? const Center(
                    child: Text('Нет данных для выбранного периода.'),
                  )
                : ListView.builder(
                    itemCount: pageState.groupedTransactions.length,
                    itemBuilder: (context, index) {
                      final groupedItem = pageState.groupedTransactions[index];
                      final color = _getChartColor(
                        index,
                      ); // Используем тот же цвет, что и в графике
                      return _CategoryGroupListItem(
                        groupedItem: groupedItem,
                        theme: theme,
                        isIncome: widget.isIncome,
                        itemColor: color, // Передаем цвет в List Item
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getChartColor(int index) {
    final List<Color> chartColors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.yellow,
      Colors.teal,
      Colors.cyan,
    ];
    return chartColors[index % chartColors.length];
  }

  Widget _buildDateRow(
    BuildContext context,
    String label,
    DateTime date,
    Function(DateTime) onDateSelected,
  ) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 5.0,
        top: 2.0,
        bottom: 2.0,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
      ),
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
                lastDate: DateTime.now().add(const Duration(days: 365)),
                locale: const Locale('ru', 'RU'),
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
}

class _CategoryGroupListItem extends StatelessWidget {
  final GroupedCategoryTransactions groupedItem;
  final ThemeData theme;
  final bool? isIncome;
  final Color itemColor;

  const _CategoryGroupListItem({
    required this.groupedItem,
    required this.theme,
    required this.isIncome,
    required this.itemColor,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleText = groupedItem.latestTransaction != null
        ? groupedItem.latestTransaction!.comment ??
              groupedItem.latestTransaction!.category.name
        : 'Нет транзакций';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        leading: Container(
          // Оборачиваем emoji в контейнер для цвета
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: itemColor.withOpacity(0.2), // Слегка прозрачный фон
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              groupedItem.category.emoji,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
        title: Text(
          groupedItem.category.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitleText,
          style: TextStyle(
            fontSize: 14,
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${groupedItem.totalAmount.toStringAsFixed(2)} ₽',
              style: TextStyle(
                color: groupedItem.category.isIncome
                    ? Colors.green
                    : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
        onTap: () {
          context.push(
            '/transactions_by_category',
            extra: groupedItem.transactions,
          );
        },
      ),
    );
  }
}

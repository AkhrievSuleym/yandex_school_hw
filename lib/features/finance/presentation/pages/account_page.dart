import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:yandex_shmr_hw/core/extensions/currency_extension.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/balance_data_point.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/enums/currency.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/edit_account_page_notifier.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/get_account_page_notifier.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/states/account/get_account_notifier_state.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/widgets/currency_selection_widget.dart';

class AccountPage extends ConsumerStatefulWidget {
  // Изменяем на ConsumerStatefulWidget
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage>
    with SingleTickerProviderStateMixin {
  bool _isFaceDown = false; // Флаг, указывающий, перевёрнуто ли устройство
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;
  late AnimationController _animationController;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _blurAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Подписка на события акселерометра
    _accelerometerSubscription = accelerometerEvents.listen((
      AccelerometerEvent event,
    ) {
      // Проверяем ось Z: если z < -8, устройство перевёрнуто экраном вниз
      setState(() {
        _isFaceDown = event.z < -8.0;
      });

      if (_isFaceDown) {
        _animationController.forward(); // Скрываем баланс
      } else {
        _animationController.reverse(); // Показываем баланс
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(accountPageNotifierProvider.notifier)
          .loadAccountDetails(accountId: 1); // Предполагаем ID 1
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountState = ref.watch(accountPageNotifierProvider);
    final accountNotifier = ref.read(accountPageNotifierProvider.notifier);
    final theme = Theme.of(context);

    final List<BalanceDataPoint> chartData = accountState.chartBalanceData;
    final ChartPeriod selectedChartPeriod = accountState.selectedChartPeriod;
    final bool isChartLoading = accountState.isChartLoading;
    final String? chartErrorMessage = accountState.chartErrorMessage;

    void navigateToEditAccount() {
      if (accountState.account != null) {
        context.go('/balance/edit');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Счет не загружен для редактирования.')),
        );
      }
    }

    Future<void> showCurrencySelector() async {
      if (accountState.account == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Счет не загружен для изменения валюты.'),
          ),
        );
        return;
      }

      final selectedCurrency = await showModalBottomSheet<Currency>(
        context: context,
        builder: (BuildContext context) {
          return CurrencySelectionModal(
            currentCurrency: accountState.account!.currency,
          );
        },
      );

      if (selectedCurrency != null &&
          selectedCurrency != accountState.account!.currency) {
        final editNotifier = ref.read(
          editAccountPageNotifierProvider(1).notifier,
        );

        editNotifier.updateName(accountState.account!.name);
        editNotifier.updateBalance(accountState.account!.balance);
        editNotifier.updateCurrency(selectedCurrency);

        final success = await editNotifier.saveAccount();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Валюта успешно обновлена на ${selectedCurrency.displayName}',
              ),
            ),
          );
          accountNotifier.loadAccountDetails(
            accountId: 1,
          ); // Перезагрузить данные основного счета
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка при обновлении валюты')),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Мой счет'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: theme.iconTheme.color),
            iconSize: 30,
            onPressed: () {
              navigateToEditAccount();
            },
          ),
        ],
        actionsPadding: const EdgeInsets.only(right: 5.0),
      ),

      body: accountState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : accountState.error != null
          ? Center(
              child: Text(
                'Ошибка: ${accountState.error!.message}',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.red),
              ),
            )
          : accountState.account == null
          ? Center(
              child: Text(
                'Нет данных о счете',
                style: theme.textTheme.bodyLarge,
              ),
            )
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 5.0,
                    top: 2.0,
                  ),
                  color: theme.cardColor,
                  child: Column(
                    children: [
                      _buildAccountDetailRow(
                        context,
                        icon: Icon(Icons.person_2_outlined),
                        label: accountState.account!.name,
                        valueWidget: Text(
                          '${accountState.account!.balance} ${accountState.account!.currency.currencySymbol}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: navigateToEditAccount,
                      ),
                      const Divider(),
                      _buildAccountDetailRow(
                        context,
                        icon: Icon(
                          accountState.account!.currency.iconData,
                        ), // Иконка текущей валюты
                        label: 'Валюта',
                        valueWidget: Text(
                          accountState.account!.currency.currencySymbol,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ), // Символ валюты
                        onTap:
                            showCurrencySelector, // Открытие модального окна выбора валюты
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ToggleButtons(
                              isSelected: [
                                selectedChartPeriod == ChartPeriod.daily,
                                selectedChartPeriod == ChartPeriod.monthly,
                              ],
                              onPressed: (int index) {
                                if (index == 0) {
                                  accountNotifier.setSelectedChartPeriod(
                                    ChartPeriod.daily,
                                  );
                                } else {
                                  accountNotifier.setSelectedChartPeriod(
                                    ChartPeriod.monthly,
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(8.0),
                              selectedColor: Colors.white,
                              fillColor: theme.colorScheme.primary,
                              color: theme.colorScheme.primary,
                              children: const <Widget>[
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Text('Дни'),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Text('Месяцы'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: isChartLoading
                              ? const Center(child: CircularProgressIndicator())
                              : chartErrorMessage != null
                              ? Center(
                                  child: Text(
                                    'Ошибка загрузки графика: $chartErrorMessage',
                                  ),
                                )
                              : chartData.isEmpty
                              ? const Center(
                                  child: Text('Нет данных для графика.'),
                                )
                              : BarChart(
                                  _buildBarChartData(
                                    chartData,
                                    theme,
                                    selectedChartPeriod,
                                    accountState.account!.currency,
                                  ),
                                  swapAnimationDuration: const Duration(
                                    milliseconds: 500,
                                  ),
                                  swapAnimationCurve: Curves.easeOut,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // Метод для построения данных BarChart (изменили сигнатуру, чтобы принимать ChartPeriod)
  BarChartData _buildBarChartData(
    List<BalanceDataPoint> data,
    ThemeData theme,
    ChartPeriod selectedPeriod,
    Currency currency,
  ) {
    // Находим минимальный и максимальный баланс для корректного масштабирования оси Y
    double minBalance = data
        .map((e) => e.amount)
        .reduce((a, b) => a < b ? a : b);
    double maxBalance = data
        .map((e) => e.amount)
        .reduce((a, b) => a > b ? a : b);

    final double yAxisMin = minBalance < 0 ? minBalance * 1.1 : 0;
    final double yAxisMax = maxBalance > 0 ? maxBalance * 1.1 : 0;

    double horizontalInterval = (maxBalance - minBalance).abs() / 4;
    if (horizontalInterval < 100 && horizontalInterval != 0)
      horizontalInterval = 100;
    if (horizontalInterval == 0 && maxBalance != 0)
      horizontalInterval = maxBalance / 4;
    if (horizontalInterval == 0 && minBalance != 0)
      horizontalInterval = minBalance.abs() / 4;
    if (horizontalInterval == 0)
      horizontalInterval = 1000; // Для случая если все значения 0

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: yAxisMax,
      minY: yAxisMin,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) =>
              Colors.black.withOpacity(0.7), // Теперь это функция
          tooltipBorderRadius: BorderRadius.circular(8.0),
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final double value = rod.toY;
            final DateTime date = data[groupIndex].date;
            final DateFormat formatter = selectedPeriod == ChartPeriod.daily
                ? DateFormat('dd.MM.yyyy')
                : DateFormat('MM.yyyy');

            final String formattedValue = NumberFormat.currency(
              locale: 'ru_RU',
              symbol: currency.currencySymbol,
              decimalDigits: 2,
            ).format(value);

            return BarTooltipItem(
              '${formatter.format(date)}\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: formattedValue,
                  style: TextStyle(
                    color: value >= 0 ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final int index = value.toInt();
              if (index < 0 || index >= data.length) {
                return const Text('');
              }
              final DateTime date = data[index].date;
              final DateFormat formatter = selectedPeriod == ChartPeriod.daily
                  ? DateFormat('dd.MM')
                  : DateFormat('MMM');

              return SideTitleWidget(
                space: 4.0,
                meta: meta,
                child: Text(
                  formatter.format(date),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              );
            },
            reservedSize: 22,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,

            getTitlesWidget: (value, meta) {
              return Text(
                NumberFormat.compact(locale: 'ru_RU').format(value),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              );
            },
            reservedSize: 32,
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        drawVerticalLine: true,
        horizontalInterval: horizontalInterval,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) =>
            FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 0.5),
        getDrawingVerticalLine: (value) =>
            FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 0.5),
      ),
      barGroups: data.asMap().entries.map((entry) {
        final index = entry.key;
        final dataPoint =
            entry.value; // Имя переменной изменено с 'data' на 'dataPoint'
        final isPositive = dataPoint.amount >= 0;
        final Color barColor = isPositive ? Colors.green : Colors.red;

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: dataPoint.amount,
              color: barColor,
              width: selectedPeriod == ChartPeriod.daily ? 5 : 10,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildAccountDetailRow(
    BuildContext context, {
    required Widget icon,
    required String label,
    required Widget valueWidget,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(label, style: theme.textTheme.bodyLarge?.copyWith()),
            ),
            valueWidget,
            const SizedBox(width: 8.0),
            Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

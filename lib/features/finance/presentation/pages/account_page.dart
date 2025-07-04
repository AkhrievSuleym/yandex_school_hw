import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:yandex_shmr_hw/core/extensions/currency_extension.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/enums/currency.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/edit_account_page_notifier.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/get_account_page_notifier.dart';
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
                // Место для графика (пока без реализации)
                // Expanded(
                //   child: Container(
                //     color: AppColors
                //         .background, // Фоновый цвет остальной части экрана
                //     child: Center(
                //       child: Text(
                //         'Место для графика',
                //         style: theme.textTheme.bodyMedium?.copyWith(
                //           color: AppColors.textSecondary,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shake/shake.dart';
import 'package:yandex_shmr_hw/core/extensions/currency_extension.dart';
import 'package:yandex_shmr_hw/core/theme/app_theme.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/enums/currency.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/edit_account_page_notifier.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/get_account_page_notifier.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/widgets/animated_spoiler_text.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/widgets/currency_selection_widget.dart';

class AccountPage extends ConsumerStatefulWidget {
  // Изменяем на ConsumerStatefulWidget
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  static const double _faceDownThreshold = -8.5; // Z < -8.5 (ближе к -9.8)
  static const double _faceUpThreshold = 8.5; // Z > 8.5 (ближе к 9.8)
  static const double _horizontalTolerance = 2.0; // Отклонение от 0 по X/Y
  bool _isCurrentlyFaceDown = false;

  @override
  void initState() {
    super.initState();
    _startAccelerometerListening();
  }

  void _startAccelerometerListening() {
    _accelerometerSubscription =
        accelerometerEventStream(
          samplingPeriod: const Duration(milliseconds: 200),
        ).listen(
          // Увеличил samplingPeriod
          (AccelerometerEvent event) {
            final double x = event.x;
            final double y = event.y;
            final double z = event.z;

            // Проверка, лежит ли устройство относительно горизонтально
            final bool isHorizontal =
                x.abs() < _horizontalTolerance &&
                y.abs() < _horizontalTolerance;

            // Проверка на "лицом вниз"
            final bool detectedFaceDown =
                isHorizontal && z < _faceDownThreshold;

            // Проверка на "лицом вверх"
            final bool detectedFaceUp = isHorizontal && z > _faceUpThreshold;

            // Логика переключения состояния скрытия баланса
            // Переключаем только при изменении состояния "лицом вниз"
            if (detectedFaceDown && !_isCurrentlyFaceDown) {
              _isCurrentlyFaceDown = true;
              _toggleAndShowSnackbar(true); // Переключить на скрытие
            } else if (detectedFaceUp && _isCurrentlyFaceDown) {
              // Если было "лицом вниз" и теперь "лицом вверх", переключаем обратно
              _isCurrentlyFaceDown = false;
              _toggleAndShowSnackbar(false); // Переключить на показ
            }
          },
          onError: (e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Ошибка сенсора: $e')));
          },
          cancelOnError: true,
        );
  }

  void _toggleAndShowSnackbar(bool isNowBlurred) {
    ref
        .read(accountPageNotifierProvider.notifier)
        .toggleBalanceBlur(); // Используем getAccountPageNotifierProvider
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isNowBlurred ? 'Баланс скрыт' : 'Баланс показан'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel(); // Отменяем подписку при диспоузе
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
                        valueWidget: AnimatedSpoilerText(
                          text:
                              '${accountState.account!.balance} ${accountState.account!.currency.currencySymbol}',
                          isBlurred: accountState.isBalanceBlurred,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: accountState.account!.balance.startsWith('-')
                                ? Colors.redAccent
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          blurColor: Colors.black,
                        ), // Символ валюты
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

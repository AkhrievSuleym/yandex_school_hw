import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:yandex_shmr_hw/core/extensions/currency_extension.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/enums/currency.dart';

class CurrencySelectionModal extends StatelessWidget {
  final Currency currentCurrency;

  const CurrencySelectionModal({super.key, required this.currentCurrency});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Все доступные валюты (для демонстрации)
    final List<Currency> availableCurrencies = Currency.values;

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor, // Фон из темы
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SizedBox(width: 40, height: 4),
          ),
          Expanded(
            child: ListView.builder(
              itemCount:
                  availableCurrencies.length + 1, // +1 для кнопки "Отмена"
              itemBuilder: (context, index) {
                if (index < availableCurrencies.length) {
                  final currency = availableCurrencies[index];
                  return ListTile(
                    leading: Icon(currency.iconData),
                    title: Text(
                      '${currency.displayName} ${currency.currencySymbol}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: currency == currentCurrency
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: currency == currentCurrency
                        ? Icon(Icons.check) // Галочка для выбранной
                        : null,
                    onTap: () {
                      context.pop(currency); // Возвращаем выбранную валюту
                    },
                  );
                } else {
                  // Кнопка "Отмена"
                  return ListTile(
                    leading: Icon(Icons.cancel),
                    title: Text(
                      'Отмена',
                      style: theme.textTheme.bodyLarge?.copyWith(),
                    ),
                    onTap: () {
                      context
                          .pop(); // Просто закрываем модальное окно без выбора
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

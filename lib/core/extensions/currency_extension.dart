import 'package:flutter/material.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/enums/currency.dart'; // Для IconData

extension CurrencyIconExtension on Currency {
  /// Возвращает соответствующую иконку Material Icons для валюты.
  IconData get iconData {
    switch (this) {
      case Currency.rub:
        return Icons.currency_ruble;
      case Currency.usd:
        return Icons.attach_money;
      case Currency.eur:
        return Icons.euro;
    }
  }

  /// Возвращает символ валюты для отображения (если нужно)
  String get currencySymbol {
    switch (this) {
      case Currency.rub:
        return '₽';
      case Currency.usd:
        return '\$';
      case Currency.eur:
        return '€';
    }
  }

  /// Возвращает читаемое название валюты (для отображения в UI)
  String get displayName {
    switch (this) {
      case Currency.rub:
        return 'Российский рубль ₽';
      case Currency.usd:
        return 'Американский доллар \$';
      case Currency.eur:
        return 'Евро €';
    }
  }
}

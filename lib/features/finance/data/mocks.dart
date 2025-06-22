// lib/features/finance/data/mock/transactions_mock_data.dart

import 'dart:math'; // <--- Добавляем импорт Random
import 'package:yandex_shmr_hw/features/finance/data/models/category/category_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_model.dart';

abstract class CategoriesMockData {
  static final categories = [
    {"id": 1, "name": "Зарплата", "emoji": "💰", "isIncome": true},
    {"id": 2, "name": "Фриланс", "emoji": "💻", "isIncome": true},
    {"id": 3, "name": "Подарки", "emoji": "🎁", "isIncome": true},
    {"id": 4, "name": "Проценты по вкладам", "emoji": "🏦", "isIncome": true},
    {"id": 5, "name": "Возврат долга", "emoji": "🔄", "isIncome": true},
    {"id": 6, "name": "Продажа имущества", "emoji": "🏠", "isIncome": true},
    {"id": 7, "name": "Жильё", "emoji": "🏠", "isIncome": false},
    {"id": 8, "name": "Продукты", "emoji": "🍎", "isIncome": false},
    {"id": 9, "name": "Транспорт", "emoji": "🚗", "isIncome": false},
    {"id": 10, "name": "Развлечения", "emoji": "🎭", "isIncome": false},
    {"id": 11, "name": "Рестораны", "emoji": "🍽️", "isIncome": false},
    {"id": 12, "name": "Одежда", "emoji": "👕", "isIncome": false},
    {"id": 13, "name": "Здоровье", "emoji": "🏥", "isIncome": false},
    {"id": 14, "name": "Коммунальные услуги", "emoji": "💡", "isIncome": false},
    {"id": 15, "name": "Техника", "emoji": "📱", "isIncome": false},
    {"id": 16, "name": "Образование", "emoji": "📚", "isIncome": false},
    {"id": 17, "name": "Путешествия", "emoji": "✈️", "isIncome": false},
    {"id": 18, "name": "Подписки", "emoji": "📺", "isIncome": false},
    {"id": 19, "name": "Подарки", "emoji": "🎀", "isIncome": false},
    {"id": 20, "name": "Красота", "emoji": "💄", "isIncome": false},
    {"id": 21, "name": "Спорт", "emoji": "🏋️", "isIncome": false},
    {"id": 22, "name": "Домашние животные", "emoji": "🐾", "isIncome": false},
    {"id": 23, "name": "Хобби", "emoji": "🎨", "isIncome": false},
    {"id": 24, "name": "Кредиты", "emoji": "💳", "isIncome": false},
  ];

  static List<CategoryModel> get incomeCategories => categories
      .where((cat) => cat["isIncome"] == true)
      .map((json) => CategoryModel.fromJson(json))
      .toList();

  static List<CategoryModel> get expenseCategories => categories
      .where((cat) => cat["isIncome"] == false)
      .map((json) => CategoryModel.fromJson(json))
      .toList();
}

abstract class TransactionsMockData {
  static final List<TransactionModel> _mockTransactions = [];
  static int _nextId = 1;
  static final Random _random = Random(); // <--- Инициализируем Random

  // Вспомогательная функция для генерации случайной суммы
  static String _generateRandomAmount(bool isIncome) {
    double minAmount;
    double maxAmount;

    if (isIncome) {
      minAmount = 1000.0; // Минимальный доход
      maxAmount = 150000.0; // Максимальный доход
    } else {
      minAmount = 50.0; // Минимальный расход
      maxAmount = 15000.0; // Максимальный расход
    }

    // Генерируем случайное число в заданном диапазоне
    double amount = minAmount + _random.nextDouble() * (maxAmount - minAmount);
    return amount.toStringAsFixed(2);
  }

  // Вспомогательная функция для добавления транзакции
  static void _addTransaction({
    required int accountId,
    required CategoryModel category,
    required DateTime transactionDate,
    String? comment,
  }) {
    _mockTransactions.add(
      TransactionModel(
        id: _nextId++,
        accountId: accountId,
        categoryId: category.id,
        amount: _generateRandomAmount(category.isIncome),
        transactionDate: transactionDate,
        comment:
            comment ??
            category
                .name, // Используем имя категории, если комментарий не указан
        createdAt: transactionDate,
        updatedAt: transactionDate,
      ),
    );
  }

  static List<TransactionModel> generateTransactions() {
    _mockTransactions
        .clear(); // Очищаем, чтобы генерировать заново при каждом вызове
    _nextId = 1;

    final today = DateTime.now();
    // final yesterday = today.subtract(
    //   const Duration(days: 1),
    // ); // Используем для рандомного времени
    final lastMonth = today.subtract(
      const Duration(days: 35),
    ); // Примерно месяц назад
    final twoMonthsAgo = today.subtract(
      const Duration(days: 65),
    ); // Примерно два месяца назад

    // ---- Сегодняшний день (3 дохода, 3 расхода) ----
    // Доходы
    _addTransaction(
      accountId: 1,
      category: CategoriesMockData.incomeCategories[0], // Зарплата
      transactionDate: DateTime(today.year, today.month, today.day, 10, 0, 0),
      comment: 'Аванс за текущий месяц',
    );
    _addTransaction(
      accountId: 1,
      category: CategoriesMockData.incomeCategories[1], // Фриланс
      transactionDate: DateTime(today.year, today.month, today.day, 12, 30, 0),
      comment: 'Оплата за проект "Alfa"',
    );
    _addTransaction(
      accountId: 1,
      category: CategoriesMockData.incomeCategories[2], // Подарки
      transactionDate: DateTime(today.year, today.month, today.day, 18, 15, 0),
      comment: 'Подарок от мамы',
    );

    // Расходы
    _addTransaction(
      accountId: 1,
      category: CategoriesMockData.expenseCategories[0], // Жильё
      transactionDate: DateTime(today.year, today.month, today.day, 9, 0, 0),
      comment: 'Аренда квартиры',
    );
    _addTransaction(
      accountId: 1,
      category: CategoriesMockData.expenseCategories[1], // Продукты
      transactionDate: DateTime(today.year, today.month, today.day, 11, 45, 0),
      comment: 'Покупка продуктов в Ашане',
    );
    _addTransaction(
      accountId: 1,
      category: CategoriesMockData.expenseCategories[2], // Транспорт
      transactionDate: DateTime(today.year, today.month, today.day, 17, 0, 0),
      comment: 'Оплата такси',
    );

    // ---- Предыдущий месяц (3 дохода, 3 расхода) ----
    // Выбираем случайные дни в предыдущем месяце
    final dayInLastMonth1 = lastMonth.add(const Duration(days: 5));
    final dayInLastMonth2 = lastMonth.add(const Duration(days: 15));
    final dayInLastMonth3 = lastMonth.add(const Duration(days: 25));

    // Доходы
    _addTransaction(
      accountId: 1,
      category: CategoriesMockData.incomeCategories[0], // Зарплата
      transactionDate: DateTime(
        dayInLastMonth1.year,
        dayInLastMonth1.month,
        dayInLastMonth1.day,
        10,
        0,
        0,
      ),
      comment: 'Зарплата за прошлый месяц',
    );
    _addTransaction(
      accountId: 1,
      category: CategoriesMockData.incomeCategories[3], // Проценты по вкладам
      transactionDate: DateTime(
        dayInLastMonth2.year,
        dayInLastMonth2.month,
        dayInLastMonth2.day,
        14,
        0,
        0,
      ),
      comment: 'Доход по накопительному счету',
    );
    _addTransaction(
      accountId: 1,
      category: CategoriesMockData.incomeCategories[4], // Возврат долга
      transactionDate: DateTime(
        dayInLastMonth3.year,
        dayInLastMonth3.month,
        dayInLastMonth3.day,
        16,
        0,
        0,
      ),
      comment: 'Возврат долга от Сергея',
    );

    // Расходы
    _addTransaction(
      accountId: 1,
      category: CategoriesMockData.expenseCategories[3], // Развлечения
      transactionDate: DateTime(
        dayInLastMonth1.year,
        dayInLastMonth1.month,
        dayInLastMonth1.day,
        20,
        0,
        0,
      ),
      comment: 'Поход в кино',
    );
    _addTransaction(
      accountId: 1,
      category: CategoriesMockData.expenseCategories[4], // Рестораны
      transactionDate: DateTime(
        dayInLastMonth2.year,
        dayInLastMonth2.month,
        dayInLastMonth2.day,
        19,
        0,
        0,
      ),
      comment: 'Ужин в ресторане "Белый кролик"',
    );
    _addTransaction(
      accountId: 1,
      category: CategoriesMockData.expenseCategories[5], // Одежда
      transactionDate: DateTime(
        dayInLastMonth3.year,
        dayInLastMonth3.month,
        dayInLastMonth3.day,
        15,
        0,
        0,
      ),
      comment: 'Новые джинсы',
    );

    // ---- Два месяца назад (2 дня по 2 транзакции, итого 4 дохода, 4 расхода) ----
    // Выбираем два разных дня
    final dayInTwoMonthsAgo1 = twoMonthsAgo.add(const Duration(days: 8));
    final dayInTwoMonthsAgo2 = twoMonthsAgo.add(const Duration(days: 20));

    // Доходы - День 1
    _addTransaction(
      accountId: 1,
      category: CategoriesMockData.incomeCategories[0], // Зарплата
      transactionDate: DateTime(
        dayInTwoMonthsAgo1.year,
        dayInTwoMonthsAgo1.month,
        dayInTwoMonthsAgo1.day,
        10,
        0,
        0,
      ),
      comment: 'Зарплата за позапрошлый месяц',
    );
    _addTransaction(
      accountId: 1,
      category: CategoriesMockData.incomeCategories[1], // Фриланс
      transactionDate: DateTime(
        dayInTwoMonthsAgo1.year,
        dayInTwoMonthsAgo1.month,
        dayInTwoMonthsAgo1.day,
        14,
        0,
        0,
      ),
      comment: 'Выплата за проект "Beta"',
    );
    // Доходы - День 2
    _addTransaction(
      accountId: 1,
      category: CategoriesMockData.incomeCategories[5], // Продажа имущества
      transactionDate: DateTime(
        dayInTwoMonthsAgo2.year,
        dayInTwoMonthsAgo2.month,
        dayInTwoMonthsAgo2.day,
        11,
        0,
        0,
      ),
      comment: 'Продажа старого велосипеда',
    );
    _addTransaction(
      accountId: 1,
      category: CategoriesMockData.incomeCategories[2], // Подарки
      transactionDate: DateTime(
        dayInTwoMonthsAgo2.year,
        dayInTwoMonthsAgo2.month,
        dayInTwoMonthsAgo2.day,
        17,
        0,
        0,
      ),
      comment: 'Подарок на день рождения',
    );

    // Расходы - День 1
    _addTransaction(
      accountId: 1,
      category: CategoriesMockData.expenseCategories[6], // Здоровье
      transactionDate: DateTime(
        dayInTwoMonthsAgo1.year,
        dayInTwoMonthsAgo1.month,
        dayInTwoMonthsAgo1.day,
        12,
        0,
        0,
      ),
      comment: 'Прием у стоматолога',
    );
    _addTransaction(
      accountId: 1,
      category: CategoriesMockData.expenseCategories[7], // Коммунальные услуги
      transactionDate: DateTime(
        dayInTwoMonthsAgo1.year,
        dayInTwoMonthsAgo1.month,
        dayInTwoMonthsAgo1.day,
        16,
        0,
        0,
      ),
      comment: 'Оплата ЖКУ за март',
    );
    // Расходы - День 2
    _addTransaction(
      accountId: 1,
      category: CategoriesMockData.expenseCategories[8], // Техника
      transactionDate: DateTime(
        dayInTwoMonthsAgo2.year,
        dayInTwoMonthsAgo2.month,
        dayInTwoMonthsAgo2.day,
        13,
        0,
        0,
      ),
      comment: 'Покупка нового телефона',
    );
    _addTransaction(
      accountId: 1,
      category: CategoriesMockData.expenseCategories[9], // Образование
      transactionDate: DateTime(
        dayInTwoMonthsAgo2.year,
        dayInTwoMonthsAgo2.month,
        dayInTwoMonthsAgo2.day,
        19,
        0,
        0,
      ),
      comment: 'Курсы по дизайну',
    );

    return _mockTransactions;
  }
}

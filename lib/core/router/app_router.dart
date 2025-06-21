import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/pages/home_page.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/pages/transactions_page.dart';

class AppRouteNames {
  static const String expenses = 'expenses';
  static const String income = 'income';
  static const String balance = 'balance';
  static const String articles = 'articles';
  static const String settings = 'settings';
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/expenses',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return HomePage(child: child);
      },
      routes: [
        GoRoute(
          path: '/expenses',
          name: AppRouteNames.expenses,
          builder: (context, state) => TransactionsPage(isIncome: false),
        ),
        GoRoute(
          path: '/income',
          name: AppRouteNames.income,
          builder: (context, state) => TransactionsPage(isIncome: true),
        ),
        GoRoute(
          path: '/balance',
          name: AppRouteNames.balance,
          builder: (context, state) => Center(child: Text('Баланс скоро')),
        ),
        GoRoute(
          path: '/articles',
          name: AppRouteNames.articles,
          builder: (context, state) => Center(child: Text('Статьи скоро')),
        ),
        GoRoute(
          path: '/settings',
          name: AppRouteNames.settings,
          builder: (context, state) => Center(
            child: Text('Настройки скоро'),
          ), // Экран контента для настроек
        ),
      ],
    ),
  ],
);

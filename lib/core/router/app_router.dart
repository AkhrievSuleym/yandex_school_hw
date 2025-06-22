import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/pages/history_page.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/pages/root_page.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/pages/transactions_page.dart';

final appRouter = GoRouter(
  initialLocation: '/expenses',
  routes: [
    // BottomNavigationBar
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          RootPage(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/expenses',
              builder: (context, state) => TransactionsPage(isIncome: false),
              routes: [
                GoRoute(
                  path: 'history',
                  builder: (context, state) => HistoryPage(isIncome: false),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/income',
              builder: (context, state) => TransactionsPage(isIncome: true),
              routes: [
                GoRoute(
                  path: 'history',
                  builder: (context, state) => HistoryPage(isIncome: true),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/balance',
              builder: (context, state) => Center(child: Text('Баланс скоро')),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/articles',
              builder: (context, state) => Center(child: Text('Статьи скоро')),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => Center(
                child: Text('Настройки скоро'),
              ), // Экран контента для настроек
            ),
          ],
        ),
      ],
    ),
  ],
);

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_response_model.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/pages/account_page.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/pages/category_page.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/pages/root_page.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/pages/transactions_by_category_page.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/pages/transactions_page.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/pages/history_page.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/pages/analysis_page.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/pages/settings_page.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/pages/update_transaction_page.dart';

final String assetDownTrend = 'assets/icons/down_trend.svg';
final String assetUpTrend = 'assets/icons/up_trend.svg';
final String assetCalculator = 'assets/icons/calculator.svg';
final String assetBarChartSide = 'assets/icons/bar_chart_side.svg';
final String assetSettings = 'assets/icons/settings.svg';

final GoRouter appRouter = GoRouter(
  initialLocation: '/expenses',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return RootPage(navigationShell: navigationShell);
      },
      branches: [
        // Ветка для Expenses
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/expenses',
              builder: (context, state) =>
                  const TransactionsPage(isIncome: false),
              routes: [
                GoRoute(
                  path: 'history',
                  builder: (context, state) =>
                      const HistoryPage(isIncome: false),
                  routes: [
                    GoRoute(
                      path: 'analysis',
                      builder: (context, state) =>
                          const AnalysisPage(isIncome: false),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'update/:transactionId',
                  pageBuilder: (context, state) {
                    final transactionId = int.parse(
                      state.pathParameters['transactionId']!,
                    );
                    return MaterialPage(
                      child: UpdateTransactionPage(
                        transactionId: transactionId,
                        isIncome: false,
                      ),
                      fullscreenDialog: true,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        // Ветка для Income
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/income',
              builder: (context, state) =>
                  const TransactionsPage(isIncome: true),
              routes: [
                GoRoute(
                  path: 'history',
                  builder: (context, state) =>
                      const HistoryPage(isIncome: true),
                  routes: [
                    GoRoute(
                      path: 'analysis',
                      builder: (context, state) =>
                          const AnalysisPage(isIncome: true),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        // Ветка для Balance
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/balance',
              builder: (context, state) => const AccountPage(),
            ),
          ],
        ),
        // Ветка для Articles
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/articles',
              builder: (context, state) => const CategoryPage(),
            ),
          ],
        ),
        // Ветка для Settings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/transactions_by_category',
      builder: (context, state) {
        final transactions = state.extra as List<TransactionResponseModel>;
        return TransactionsByCategoryPage(transactions: transactions);
      },
    ),
  ],
);

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_response_model.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/pages/account_page.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/pages/analysis_page.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/pages/category_page.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/pages/edit_account_page.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/pages/history_page.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/pages/root_page.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/pages/transactions_by_category_page.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/pages/transactions_page.dart';

final String assetDownTrend = 'assets/icons/down_trend.svg';
final String assetUpTrend = 'assets/icons/up_trend.svg';
final String assetCalculator = 'assets/icons/calculator.svg';
final String assetBarChartSide = 'assets/icons/bar_chart_side.svg';
final String assetSettings = 'assets/icons/settings.svg';

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
                  path: '/history',
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
                  path: '/history',
                  builder: (context, state) => HistoryPage(isIncome: true),
                  routes: [
                    // GoRoute(
                    //   path: '/analysis',
                    //   builder: (context, state) => AnalysisPage(),
                    //   routes: [
                    //     GoRoute(
                    //       path: '/category',
                    //       builder: (context, state) {
                    //         final transactions =
                    //             state.extra as List<TransactionResponseModel>;
                    //         return TransactionsByCategoryPage(
                    //           transactions: transactions,
                    //         );
                    //       },
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/balance',
              builder: (context, state) => AccountPage(),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) => EditAccountPage(accountId: 1),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/articles',
              builder: (context, state) => CategoryPage(),
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

    GoRoute(
      path: '/analysis_income',
      builder: (context, state) => AnalysisPage(isIncome: true),
    ),
    GoRoute(
      path: '/analysis_expenses',
      builder: (context, state) => AnalysisPage(isIncome: false),
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

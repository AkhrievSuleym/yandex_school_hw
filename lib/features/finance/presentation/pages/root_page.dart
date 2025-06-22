import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yandex_shmr_hw/core/theme/app_theme.dart';

class RootPage extends StatelessWidget {
  const RootPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.trending_down),
            //AppLocalizations.of(context)!.tabExpenses
            label: "Расходы",
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.trending_up),
            //AppLocalizations.of(context)!.tabIncome
            label: "Доходы",
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calculate),
            //AppLocalizations.of(context)!.balance
            label: "Счет",
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.view_list),
            //AppLocalizations.of(context)!.articles
            label: "Статьи",
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            //AppLocalizations.of(context)!.settings
            label: "Настройки",
          ),
        ],
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        selectedItemColor: Theme.of(
          context,
        ).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: Theme.of(
          context,
        ).bottomNavigationBarTheme.unselectedItemColor,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor:
            Theme.of(
              context,
            ).elevatedButtonTheme.style?.backgroundColor?.resolve({}) ??
            AppColors.buttonLight,
        child: const Icon(Icons.add),
      ),
    );
  }
}

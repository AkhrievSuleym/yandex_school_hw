import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yandex_shmr_hw/core/router/app_router.dart';
import 'package:yandex_shmr_hw/core/theme/app_theme.dart';
import 'package:yandex_shmr_hw/l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  final Widget child;

  const HomePage({super.key, required this.child});
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // По умолчанию Расходы (индекс 0)

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String location = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.uri.path;
    _selectedIndex = _getCurrentIndex(location);
  }

  int _getCurrentIndex(String location) {
    if (location.startsWith('/expenses')) return 0;
    if (location.startsWith('/income')) return 1;
    if (location.startsWith('/balance')) return 2;
    if (location.startsWith('/articles')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0; // Дефолтное значение
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        context.goNamed(AppRouteNames.expenses);
        break;
      case 1:
        context.goNamed(AppRouteNames.income);
        break;
      case 2:
        context.goNamed(AppRouteNames.balance);
        break;
      case 3:
        context.goNamed(AppRouteNames.articles);
        break;
      case 4:
        context.goNamed(AppRouteNames.settings);
        break;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.trending_down),
            label: AppLocalizations.of(context)!.tabExpenses,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.trending_up),
            label: AppLocalizations.of(context)!.tabIncome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calculate),
            label: AppLocalizations.of(context)!.balance,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.view_list),
            label: AppLocalizations.of(context)!.articles,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: AppLocalizations.of(context)!.settings,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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

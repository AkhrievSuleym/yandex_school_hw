import 'package:flutter/material.dart';
import 'package:yandex_shmr_hw/core/theme/app_theme.dart'; // Убедитесь, что путь верный
import 'package:yandex_shmr_hw/l10n/app_localizations.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.titleExpenses),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: Theme.of(context).iconTheme.color),
            iconSize: 30,
            onPressed: () {
              setState(() {});
            },
          ),
        ],
        actionsPadding: EdgeInsets.only(right: 5.0),
      ),
      body: Container(),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_down),
            label: AppLocalizations.of(context)!.tabExpenses,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: AppLocalizations.of(context)!.tabIncome,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: AppLocalizations.of(context)!.balance,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            label: AppLocalizations.of(context)!.articles,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: AppLocalizations.of(context)!.settings,
          ),
        ],
        currentIndex: _selectedIndex, // Активная вкладка
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(
          context,
        ).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: Theme.of(
          context,
        ).bottomNavigationBarTheme.unselectedItemColor,
        type: BottomNavigationBarType
            .fixed, // Фиксированный тип для отображения всех меток
        showUnselectedLabels: true, // Явно включаем метки неактивных вкладок
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor:
            Theme.of(
              context,
            ).elevatedButtonTheme.style?.backgroundColor?.resolve({}) ??
            AppColors.buttonLight,
        child: Icon(Icons.add),
      ),
    );
  }
}

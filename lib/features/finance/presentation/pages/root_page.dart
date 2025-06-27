import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:yandex_shmr_hw/core/theme/app_theme.dart';

class RootPage extends StatelessWidget {
  const RootPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  final String assetDownTrend = 'assets/icons/down_trend.svg';
  final String assetUpTrend = 'assets/icons/up_trend.svg';
  final String assetCalculator = 'assets/icons/calculator.svg';
  final String assetBarChartSide = 'assets/icons/bar_chart_side.svg';
  final String assetSettings = 'assets/icons/settings.svg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              assetDownTrend,
              colorFilter: ColorFilter.mode(
                Theme.of(context).bottomNavigationBarTheme.unselectedItemColor!,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              assetDownTrend,
              colorFilter: ColorFilter.mode(
                Theme.of(context).bottomNavigationBarTheme.selectedItemColor!,
                BlendMode.srcIn,
              ),
            ),
            //AppLocalizations.of(context)!.tabExpenses
            label: "Расходы",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              assetUpTrend,
              colorFilter: ColorFilter.mode(
                Theme.of(context).bottomNavigationBarTheme.unselectedItemColor!,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              assetUpTrend,
              colorFilter: ColorFilter.mode(
                Theme.of(context).bottomNavigationBarTheme.selectedItemColor!,
                BlendMode.srcIn,
              ),
            ),
            //AppLocalizations.of(context)!.tabIncome
            label: "Доходы",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              assetCalculator,
              colorFilter: ColorFilter.mode(
                Theme.of(context).bottomNavigationBarTheme.unselectedItemColor!,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              assetCalculator,
              colorFilter: ColorFilter.mode(
                Theme.of(context).bottomNavigationBarTheme.selectedItemColor!,
                BlendMode.srcIn,
              ),
            ),
            //AppLocalizations.of(context)!.balance
            label: "Счет",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              assetBarChartSide,
              colorFilter: ColorFilter.mode(
                Theme.of(context).bottomNavigationBarTheme.unselectedItemColor!,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              assetBarChartSide,
              colorFilter: ColorFilter.mode(
                Theme.of(context).bottomNavigationBarTheme.selectedItemColor!,
                BlendMode.srcIn,
              ),
            ),
            //AppLocalizations.of(context)!.articles
            label: "Статьи",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              assetSettings,
              colorFilter: ColorFilter.mode(
                Theme.of(context).bottomNavigationBarTheme.unselectedItemColor!,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              assetSettings,
              colorFilter: ColorFilter.mode(
                Theme.of(context).bottomNavigationBarTheme.selectedItemColor!,
                BlendMode.srcIn,
              ),
            ),
            //AppLocalizations.of(context)!.settings
            label: "Настройки",
          ),
        ],
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
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

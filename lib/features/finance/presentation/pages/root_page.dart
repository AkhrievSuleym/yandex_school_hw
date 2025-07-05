import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:yandex_shmr_hw/core/router/app_router.dart';
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
    );
  }
}

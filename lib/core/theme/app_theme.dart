import 'package:flutter/material.dart';

class AppColors {
  static const appBarLight = Color(0xFF2AE881);
  static const backgroundLight = Color(0xFFFEF7FF);
  static const textLight = Color(0xFF1D1B20);
  static const iconsLight = Color(0xFF49454F);
  static const navBarLight = Color(0xFFF3EDF7);
  static const buttonLight = Color(0xFF2AE881);
  static const accentLight = Color(0xFFD4FAE6);

  static const appBarDark = Color(0xFF1AA864);
  static const backgroundDark = Color(0xFF1C1C1E);
  static const textDark = Color(0xFFE0E0E0);
  static const iconsDark = Color(0xFFB39DDB);
  static const navBarDark = Color(0xFF2C2C2E);
  static const buttonDark = Color(0xFF1AA864);
  static const accentDark = Color(0xFF4A4062);
}

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.appBarLight,
  scaffoldBackgroundColor: AppColors.backgroundLight,
  textTheme: TextTheme(bodyMedium: TextStyle(color: AppColors.textLight)),
  iconTheme: IconThemeData(color: AppColors.iconsLight),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.navBarLight,
    unselectedItemColor: AppColors.iconsLight,
    selectedItemColor: AppColors.buttonLight,
    unselectedLabelStyle: TextStyle(color: AppColors.textLight),
    selectedLabelStyle: TextStyle(color: AppColors.buttonLight),
    showUnselectedLabels: true,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonLight),
  ),
  appBarTheme: AppBarTheme(backgroundColor: AppColors.appBarLight),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: AppColors.accentLight,
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.appBarDark,
  scaffoldBackgroundColor: AppColors.backgroundDark,
  textTheme: TextTheme(bodyMedium: TextStyle(color: AppColors.textDark)),
  iconTheme: IconThemeData(color: AppColors.iconsDark),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.navBarDark,
    unselectedItemColor: AppColors.iconsDark,
    selectedItemColor: AppColors.buttonDark, // Цвет активной иконки
    unselectedLabelStyle: TextStyle(color: AppColors.textDark),
    selectedLabelStyle: TextStyle(color: AppColors.buttonDark),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonDark),
  ),
  appBarTheme: AppBarTheme(backgroundColor: AppColors.appBarDark),
  colorScheme: ColorScheme.fromSwatch(
    brightness: Brightness.dark,
  ).copyWith(secondary: AppColors.accentDark),
);

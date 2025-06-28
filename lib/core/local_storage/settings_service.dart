import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SettingsService {
  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const String _themeModeKey = 'themeMode';

  ThemeMode getThemeMode() {
    final String? mode = _prefs.getString(_themeModeKey);
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<bool> saveThemeMode(ThemeMode mode) {
    String modeString;
    switch (mode) {
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.system:
        modeString = 'system';
        break;
    }
    return _prefs.setString(_themeModeKey, modeString);
  }

  static const String _isInitialDataLoadedKey = 'isInitialDataLoaded';

  bool getIsInitialDataLoaded() {
    return _prefs.getBool(_isInitialDataLoadedKey) ?? false;
  }

  Future<bool> setIsInitialDataLoaded(bool loaded) {
    return _prefs.setBool(_isInitialDataLoadedKey, loaded);
  }
}

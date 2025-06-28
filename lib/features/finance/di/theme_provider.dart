import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_shmr_hw/core/local_storage/settings_service.dart';

// final hiveServiceProvider = Provider<HiveService>((ref) => HiveService());
final settingsServiceProvider = Provider<SettingsService>(
  (ref) => SettingsService(),
);

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  final settingsService = ref.watch(settingsServiceProvider);
  return ThemeModeNotifier(settingsService);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SettingsService _settingsService;
  ThemeModeNotifier(this._settingsService)
    : super(_settingsService.getThemeMode());

  void setThemeMode(ThemeMode mode) {
    state = mode;
    _settingsService.saveThemeMode(mode);
  }
}

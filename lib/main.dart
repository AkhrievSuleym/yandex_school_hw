import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_shmr_hw/core/local_storage/settings_service.dart';
import 'package:yandex_shmr_hw/core/router/app_router.dart';
import 'package:yandex_shmr_hw/core/theme/app_theme.dart';
import 'package:yandex_shmr_hw/features/finance/di/theme_provider.dart';
import 'package:yandex_shmr_hw/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize SettingsService
  final settingsService = SettingsService();
  await settingsService.init();

  // // Initialize HiveService
  // final hiveService = HiveService();
  // await hiveService.init();

  final container = ProviderContainer(
    overrides: [
      settingsServiceProvider.overrideWithValue(settingsService),
      // hiveServiceProvider.overrideWithValue(hiveService),
    ],
  );

  // Check if initial data needs to be loaded (e.g., default categories, an initial account)
  if (!settingsService.getIsInitialDataLoaded()) {
    // await _loadInitialData(container); // Pass container
    await settingsService.setIsInitialDataLoaded(true);
  }

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      routerConfig: appRouter,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [const Locale('en', ''), const Locale('ru', '')],
    );
  }
}

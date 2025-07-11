import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yandex_shmr_hw/core/router/app_router.dart';
import 'package:yandex_shmr_hw/core/theme/app_theme.dart';
import 'package:yandex_shmr_hw/core/theme/theme_notifier.dart';
import 'package:yandex_shmr_hw/features/finance/data/db/database.dart';
import 'package:yandex_shmr_hw/features/finance/data/local_datasource/account_local_datasource.dart';
import 'package:yandex_shmr_hw/l10n/app_localizations.dart';

late Database database;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDir = await getApplicationDocumentsDirectory();
  final dbPath = '${appDir.path}/dogs.db';
  final dbFile = File(dbPath);

  final dbConnection = NativeDatabase.createBackgroundConnection(dbFile);
  database = Database(dbConnection);
  final accountLocalDatasource = AccountLocalDatasource(database);

  await dotenv.load(fileName: ".env");

  runApp(ProviderScope(child: MyApp()));
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
      themeMode: themeMode ? ThemeMode.dark : ThemeMode.light,
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

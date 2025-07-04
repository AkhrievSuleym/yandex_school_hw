import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_shmr_hw/core/theme/theme_notifier.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("Настройки"), actions: []),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Switch(
              activeColor: Colors.blue,
              inactiveTrackColor: Colors.red,
              value: darkMode,
              onChanged: (val) {
                ref.read(themeModeProvider.notifier).toggle();
              },
            ),
          ],
        ),
      ),
    );
  }
}

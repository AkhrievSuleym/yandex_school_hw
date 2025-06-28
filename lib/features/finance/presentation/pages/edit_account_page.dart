import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yandex_shmr_hw/core/extensions/currency_extension.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/enums/currency.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/edit_account_page_notifier.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/get_account_page_notifier.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/states/edit_account_notifier.dart';

class EditAccountPage extends ConsumerWidget {
  final int accountId;

  const EditAccountPage({super.key, required this.accountId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editAccountPageNotifierProvider(accountId));
    final notifier = ref.read(
      editAccountPageNotifierProvider(accountId).notifier,
    );
    final theme = Theme.of(context);

    // Слушаем изменение saveSuccess, чтобы вернуться назад
    ref.listen<EditAccountPageState>(
      editAccountPageNotifierProvider(accountId),
      (previous, current) {
        if (current.saveSuccess) {
          // После успешного сохранения, обновить основной экран счета
          ref.invalidate(accountPageNotifierProvider);
          context.pop();
        } else if (current.error != null && !current.isSaving) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка: ${current.error!.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.error != null && state.originalAccount == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ошибка')),
        body: Center(
          child: Text('Не удалось загрузить счет: ${state.error!.message}'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close), // Иконка "Отмена"
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(
          'Мой счет',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: state.isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check), // Иконка "Сохранить"
            onPressed: state.isSaving
                ? null
                : () async {
                    await notifier.saveAccount();
                  },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey, // Тонкие серые стенки
              width: 1.0, // Толщина границы
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Icon(Icons.person_outlined),
              SizedBox(width: 5),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: TextEditingController(text: state.name)
                    ..selection = TextSelection.collapsed(
                      offset: state.name.length,
                    ),
                  onChanged: notifier.updateName,
                  keyboardType: TextInputType.text,
                  style: theme.textTheme.bodyLarge?.copyWith(),
                ),
              ),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: TextEditingController(text: state.balance)
                    ..selection = TextSelection.collapsed(
                      offset: state.balance.length,
                    ),
                  onChanged: notifier.updateBalance,
                  keyboardType: TextInputType.number,
                  style: theme.textTheme.bodyLarge?.copyWith(),
                ),
              ),
              Text(
                state.originalAccount!.currency.currencySymbol,
                style: TextStyle(fontSize: 17),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

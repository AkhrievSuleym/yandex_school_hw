import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/category/category_model.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/category_page_notifier.dart';

class CategoryPage extends ConsumerWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(categoryPageNotifierProvider);
    final notifier = ref.read(categoryPageNotifierProvider.notifier);
    final theme = Theme.of(context);

    // Контроллер для поля поиска
    final TextEditingController searchController = TextEditingController(
      text: state.searchQuery,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Мои статьи'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: TextField(
              controller: TextEditingController(text: state.searchQuery)
                ..selection = TextSelection.collapsed(
                  offset: state.searchQuery.length,
                ),
              onChanged: notifier.searchCategories, // Вызываем метод поиска
              decoration: InputDecoration(
                hintText: 'Найти статью',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 16.0,
                ),
              ),
              keyboardType: TextInputType.text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                ? Center(
                    child: Text(
                      'Ошибка: ${state.error!.message}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  )
                : state.filteredCategories.isEmpty &&
                      state.searchQuery.isNotEmpty
                ? Center(
                    child: Text(
                      'Нет результатов для "${state.searchQuery}"',
                      style: theme.textTheme.bodyLarge,
                    ),
                  )
                : ListView.builder(
                    itemCount: state.filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = state.filteredCategories[index];
                      return _CategoryListItem(
                        category: category,
                        theme: theme,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CategoryListItem extends StatelessWidget {
  final CategoryModel category;
  final ThemeData theme;

  const _CategoryListItem({required this.category, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: ListTile(
        leading: Text(category.emoji, style: const TextStyle(fontSize: 24)),
        title: Text(category.name, style: theme.textTheme.titleMedium),
        trailing: Icon(
          category.isIncome ? Icons.arrow_upward : Icons.arrow_downward,
          color: category.isIncome ? Colors.green : Colors.red,
        ),
        onTap: () {
          // TODO: Обработка выбора категории
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Выбрана категория: ${category.name}')),
          );
          // Например, можно вернуть выбранную категорию назад на предыдущую страницу:
          // context.pop(category);
        },
      ),
    );
  }
}

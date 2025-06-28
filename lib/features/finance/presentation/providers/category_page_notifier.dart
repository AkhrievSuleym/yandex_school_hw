import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:yandex_shmr_hw/features/finance/di/usecase_providers.dart';
import 'package:yandex_shmr_hw/features/finance/domain/usecases/categories/get_all_categories_usecase.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/states/category_page_state.dart';

final categoryPageNotifierProvider =
    StateNotifierProvider<CategoryPageNotifier, CategoryPageState>((ref) {
      // Теперь get_all_categories_usecase_provider берется из файла di
      final getAllCategories = ref.read(getAllCategoriesUseCaseProvider);
      return CategoryPageNotifier(getAllCategories);
    });

class CategoryPageNotifier extends StateNotifier<CategoryPageState> {
  final GetAllCategoriesUseCase _getAllCategories;

  CategoryPageNotifier(this._getAllCategories) : super(CategoryPageState()) {
    // Используем обычный класс
    _loadCategories();
  }
  Logger logger = Logger();

  Future<void> _loadCategories() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _getAllCategories();

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure),
      (categories) {
        state = state.copyWith(
          isLoading: false,
          categories: categories,
          filteredCategories: categories,
        );
      },
    );
  }

  void searchCategories(String query) {
    state = state.copyWith(searchQuery: query);
    if (query.isEmpty) {
      state = state.copyWith(filteredCategories: state.categories);
      return;
    }

    final lowerCaseQuery = query.toLowerCase();
    final filtered = state.categories.where((category) {
      String categoryName = category.name.toLowerCase();
      int currentQueryIndex = 0;
      for (int i = 0; i < categoryName.length; i++) {
        if (currentQueryIndex < lowerCaseQuery.length &&
            categoryName[i] == lowerCaseQuery[currentQueryIndex]) {
          currentQueryIndex++;
        }
      }
      return currentQueryIndex == lowerCaseQuery.length;
    }).toList();

    state = state.copyWith(filteredCategories: filtered);
  }
}

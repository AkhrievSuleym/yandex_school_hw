import 'package:flutter/foundation.dart'; // Для @required, если используете
import 'package:yandex_shmr_hw/core/error/failure.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/category/category_model.dart';

class CategoryPageState {
  final List<CategoryModel> categories;
  final List<CategoryModel> filteredCategories;
  final bool isLoading;
  final String searchQuery;
  final Failure? error;

  CategoryPageState({
    this.categories = const [],
    this.filteredCategories = const [],
    this.isLoading = false,
    this.searchQuery = '',
    this.error,
  });

  // Метод copyWith для удобного создания нового состояния с измененными полями
  CategoryPageState copyWith({
    List<CategoryModel>? categories,
    List<CategoryModel>? filteredCategories,
    bool? isLoading,
    String? searchQuery,
    Failure? error,
  }) {
    return CategoryPageState(
      categories: categories ?? this.categories,
      filteredCategories: filteredCategories ?? this.filteredCategories,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      error:
          error, // Здесь не используем ??, чтобы можно было сбросить ошибку в null
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CategoryPageState &&
        listEquals(other.categories, categories) &&
        listEquals(other.filteredCategories, filteredCategories) &&
        other.isLoading == isLoading &&
        other.searchQuery == searchQuery &&
        other.error == error;
  }

  @override
  int get hashCode {
    return categories.hashCode ^
        filteredCategories.hashCode ^
        isLoading.hashCode ^
        searchQuery.hashCode ^
        error.hashCode;
  }
}

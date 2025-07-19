import 'package:dio/dio.dart';
import 'package:yandex_shmr_hw/core/network/api_client.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/category/category_model.dart';

class CategoryRemoteDatasource {
  final ApiClient _apiClient;

  CategoryRemoteDatasource(this._apiClient);

  /// Получает все категории с бэкенда.
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _apiClient.getCategories();
      // Ответ ожидается в виде списка Map, поэтому маппим каждый элемент.
      return (response.data as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } on DioException {
      rethrow; // Перебрасываем ошибку выше для централизованной обработки
    }
  }

  /// Получает категории с бэкенда по их типу (доход/расход).
  /// [isIncome] - true для доходных категорий, false для расходных.
  Future<List<CategoryModel>> getCategoriesByType(bool isIncome) async {
    try {
      final response = await _apiClient.getCategoriesByType(isIncome);
      // Ответ ожидается в виде списка Map, поэтому маппим каждый элемент.
      return (response.data as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } on DioException {
      rethrow;
    }
  }
}

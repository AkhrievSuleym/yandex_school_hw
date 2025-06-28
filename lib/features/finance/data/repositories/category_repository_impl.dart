import 'package:fpdart/fpdart.dart';
import 'package:yandex_shmr_hw/core/error/failure.dart';
import 'package:yandex_shmr_hw/features/finance/data/mocks.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/category/category_model.dart';
import 'package:yandex_shmr_hw/features/finance/domain/repository/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final _mockCategories = CategoriesMockData.mockCategories
      .map((json) => CategoryModel.fromJson(json))
      .toList();
  @override
  Future<Either<Failure, List<CategoryModel>>> getAllCategories() async {
    try {
      // Имитация задержки сети
      await Future.delayed(Duration(milliseconds: 500));
      return right(_mockCategories);
    } catch (e) {
      return left(Failure('Error!'));
    }
  }

  @override
  Future<Either<Failure, List<CategoryModel>>> getCategoriesByType(
    bool isIncome,
  ) async {
    try {
      // Имитация задержки сети
      await Future.delayed(Duration(milliseconds: 500));
      return right(
        _mockCategories
            .where((category) => category.isIncome == isIncome)
            .toList(),
      );
    } catch (e) {
      return left(Failure('Error!'));
    }
  }
}

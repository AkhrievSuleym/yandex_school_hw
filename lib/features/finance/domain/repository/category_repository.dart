import 'package:either_dart/either.dart';
import 'package:yandex_shmr_hw/core/error/failure.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/category/category_model.dart';

abstract interface class CategoryRepository {
  Future<Either<Failure, List<CategoryModel>>> getAllCategories();
  Future<Either<Failure, List<CategoryModel>>> getIncomeCategories();
  Future<Either<Failure, List<CategoryModel>>> getExpenseCategories();
}

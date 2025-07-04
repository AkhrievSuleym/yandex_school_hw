import 'package:drift/drift.dart';
import 'package:yandex_shmr_hw/features/finance/data/db/database.dart';
import 'package:yandex_shmr_hw/main.dart';

class CategoriesLocalDatasource {
  Future<void> saveCategories({
    required List<CategoryTableCompanion> categoryDbList,
  }) async {
    await database.categoryTable.insertAll(categoryDbList);
  }

  Future<List<CategoryDbModel>> getAllCatgories() async {
    return await database.select(database.categoryTable).get();
  }
}

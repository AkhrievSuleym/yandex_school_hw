import 'package:drift/drift.dart';
import 'package:yandex_shmr_hw/features/finance/data/db/database.dart';
import 'package:yandex_shmr_hw/features/finance/data/mappers/category_mapper.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/category/category_model.dart';

class CategoriesLocalDatasource {
  final Database _database;

  CategoriesLocalDatasource(this._database);

  /// Получает все категории из локальной базы данных.
  Future<List<CategoryModel>> getAllCategories() async {
    final categories = await _database.select(_database.categoryTable).get();
    return categories.map((dbModel) {
      return CategoryModel(
        id:
            dbModel.serverId ??
            dbModel.id, // Используем serverId если есть, иначе локальный ID
        name: dbModel.name,
        emoji: dbModel.emoji,
        isIncome: dbModel.isIncome,
      );
    }).toList();
  }

  Future<List<CategoryModel>> getCategoriesByType(bool isIncome) async {
    final categories = await (_database.select(
      _database.categoryTable,
    )..where((tbl) => tbl.isIncome.equals(isIncome))).get();
    return categories.map((dbModel) {
      return CategoryModel(
        id: dbModel.serverId ?? dbModel.id,
        name: dbModel.name,
        emoji: dbModel.emoji,
        isIncome: dbModel.isIncome,
      );
    }).toList();
  }

  Future<void> clearAndInsertAll(List<CategoryModel> categories) async {
    await _database.transaction(() async {
      await _database.delete(_database.categoryTable).go(); // Очищаем все
      for (final category in categories) {
        await _database
            .into(_database.categoryTable)
            .insert(
              CategoryTableCompanion.insert(
                serverId: Value(
                  category.id,
                ), // Теперь category.id - это serverId
                name: category.name,
                emoji: Value(category.emoji),
                isIncome: Value(category.isIncome),
                isSynced: Value(
                  true,
                ), // Считаем, что эти данные уже синхронизированы
              ),
            );
      }
    });
  }

  Future<void> upsertCategory(CategoryModel category) async {
    final existingCategory = await (_database.select(
      _database.categoryTable,
    )..where((tbl) => tbl.serverId.equals(category.id))).getSingleOrNull();

    if (existingCategory != null) {
      await (_database.update(
        _database.categoryTable,
      )..where((tbl) => tbl.id.equals(existingCategory.id))).write(
        CategoryTableCompanion(
          name: Value(category.name),
          emoji: Value(category.emoji),
          isIncome: Value(category.isIncome),
          isSynced: Value(true),
        ),
      );
    } else {
      await _database
          .into(_database.categoryTable)
          .insert(
            CategoryTableCompanion.insert(
              serverId: Value(category.id),
              name: category.name,
              emoji: Value(category.emoji),
              isIncome: Value(category.isIncome),
              isSynced: Value(true),
            ),
          );
    }
  }
}

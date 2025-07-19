import 'package:yandex_shmr_hw/features/finance/data/db/database.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/category/category_model.dart';

extension CategoryMapper on CategoryDbModel {
  CategoryModel toModel() {
    return CategoryModel(id: id, name: name, emoji: emoji, isIncome: isIncome);
  }
}

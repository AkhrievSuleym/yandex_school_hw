import 'package:hive_ce/hive.dart';

part 'hive_category.g.dart'; // REQUIRED for Hive code generation

@HiveType(typeId: 1) // Unique typeId for each HiveType
class HiveCategory extends HiveObject {
  @HiveField(0)
  int id; // Use int for ID
  @HiveField(1)
  String name;
  @HiveField(2)
  String emoji;
  @HiveField(3)
  bool isIncome;
  @HiveField(4)
  bool isFavorite;

  HiveCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.isIncome,
    required this.isFavorite,
  });
}

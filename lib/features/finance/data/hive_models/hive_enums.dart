import 'package:hive_ce/hive.dart';

part 'hive_enums.g.dart'; // Add this line

@HiveType(typeId: 10) // Unique TypeId for the enum
enum Currency {
  @HiveField(0)
  rub, // Ruble
  @HiveField(1)
  usd, // US Dollar
  @HiveField(2)
  eur, // Euro
}

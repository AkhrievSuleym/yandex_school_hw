import 'package:hive_ce/hive.dart';
import 'package:yandex_shmr_hw/features/finance/data/hive_models/hive_enums.dart';

part 'hive_account.g.dart';

@HiveType(typeId: 0) // Unique typeId for each HiveType
class HiveAccount extends HiveObject {
  @HiveField(0)
  int id; // Use int for ID
  @HiveField(1)
  int userId;
  @HiveField(2)
  String name;
  @HiveField(3)
  String balance; // Storing as String, consider double for calculations
  @HiveField(4)
  @HiveType(typeId: 10) // Define typeId for Currency enum adapter
  Currency currency;
  @HiveField(5)
  DateTime createdAt;
  @HiveField(6)
  DateTime updatedAt;

  HiveAccount({
    required this.id,
    required this.userId,
    required this.name,
    required this.balance,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
  });
}

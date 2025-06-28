// import 'package:hive_ce/hive.dart';

// part 'hive_transaction.g.dart';

// @HiveType(typeId: 2) // Unique typeId for each HiveType
// class HiveTransaction extends HiveObject {
//   @HiveField(0)
//   int id; // Use int for ID
//   @HiveField(1)
//   int userId;
//   @HiveField(2)
//   int accountId; // Store accountId directly for simpler queries
//   @HiveField(3)
//   int categoryId; // Store categoryId directly for simpler queries
//   @HiveField(4)
//   String amount; // Storing as String, consider double for calculations
//   @HiveField(5)
//   DateTime transactionDate;
//   @HiveField(6)
//   String? comment;
//   @HiveField(7)
//   DateTime createdAt;
//   @HiveField(8)
//   DateTime updatedAt;
//   @HiveField(9)
//   bool isSynced; // NEW FIELD: For sync status

//   HiveTransaction({
//     required this.id,
//     required this.userId,
//     required this.accountId,
//     required this.categoryId,
//     required this.amount,
//     required this.transactionDate,
//     this.comment,
//     required this.createdAt,
//     required this.updatedAt,
//     this.isSynced = false, // Default to false for new local transactions
//   });
// }

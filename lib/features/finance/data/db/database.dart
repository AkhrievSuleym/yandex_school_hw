import 'package:drift/drift.dart';

part './tables/category_table.dart';
part './tables/transaction_table.dart';
part './tables/account_table.dart';
part './tables/operation_table.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [CategoryTable, TransactionTable, AccountTable, OperationTable],
)
class Database extends _$Database {
  Database(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
    );
  }
}

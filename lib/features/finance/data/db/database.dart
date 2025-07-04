import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part './tables/category_table.dart';
part './tables/transaction_table.dart';
part './tables/account_table.dart';

part 'database.g.dart';

@DriftDatabase(tables: [CategoryTable, TransactionTable, AccountTable])
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

  /// Returns an auto-updating stream of all todo entries in a given category
  /// id.
  Stream<List<CategoryDbModel>> entriesInCategory() =>
      select(categoryTable).watch();
}

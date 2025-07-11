import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_state_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/enums/change_type.dart';

part './tables/category_table.dart';
part './tables/transaction_table.dart';
part './tables/account_table.dart';
part './tables/account_history_table.dart';
part './tables/pending_sync_event_table.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    CategoryTable,
    TransactionTable,
    AccountTable,
    AccountHistoryTable,
    PendingSyncEventTable,
  ],
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

  /// Returns an auto-updating stream of all todo entries in a given category
  /// id.
  Stream<List<CategoryDbModel>> entriesInCategory() =>
      select(categoryTable).watch();

  Future<void> insertAccountHistory(AccountHistoryTableCompanion entry) =>
      into(accountHistoryTable).insert(entry);

  Future<List<AccountHistoryDbModel>> getAccountHistoryForAccount(
    int accountId,
  ) => (select(
    accountHistoryTable,
  )..where((tbl) => tbl.accountId.equals(accountId))).get();

  // Методы для работы с PendingSyncEventTable
  Future<void> insertPendingSyncEvent(PendingSyncEventTableCompanion entry) =>
      into(pendingSyncEventTable).insert(entry);

  Future<List<PendingSyncEventDbModel>> getPendingSyncEvents() => (select(
    pendingSyncEventTable,
  )..orderBy([(t) => OrderingTerm(expression: t.createdAt)])).get();

  Future<void> deletePendingSyncEvent(int id) =>
      (delete(pendingSyncEventTable)..where((tbl) => tbl.id.equals(id))).go();

  Future<void> updatePendingSyncEvent(PendingSyncEventTableCompanion event) =>
      update(pendingSyncEventTable).replace(event);
}

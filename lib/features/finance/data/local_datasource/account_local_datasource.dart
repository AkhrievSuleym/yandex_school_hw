import 'package:drift/drift.dart';
import 'package:yandex_shmr_hw/features/finance/data/db/database.dart';
import 'package:yandex_shmr_hw/main.dart';

class AccountLocalDatasource {
  Future<void> saveAccount({
    required AccountTableCompanion accountDbModel,
  }) async {
    await database.accountTable.insertOne(accountDbModel);
  }

  Future<AccountDbModel?> getAccount() async {
    return database.select(database.accountTable).getSingleOrNull();
  }

  Future<bool> updateAccount({
    required AccountTableCompanion updatedModel,
  }) async {
    final result = await database
        .update(database.accountTable)
        .write(updatedModel);
    return result > 0;
  }
}

import 'package:yandex_shmr_hw/features/finance/data/db/database.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/account/account_model.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/enums/currency.dart';

extension AccountMapper on AccountDbModel {
  AccountModel toModel() {
    return AccountModel(
      id: id,
      userId: 0,
      name: name,
      balance: balance,
      currency: Currency.values.byName(currency),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

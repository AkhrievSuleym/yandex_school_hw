part of '../database.dart';

@DataClassName('AccountHistoryDbModel')
class AccountHistoryTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get accountId => integer()();

  IntColumn get accountServerId => integer().nullable()();
  TextColumn get changeType => text().map(const ChangeTypeConverter())();
  TextColumn get previousState =>
      text().nullable().map(const AccountStateModelConverter())();
  TextColumn get newState => text().map(const AccountStateModelConverter())();

  DateTimeColumn get changeTimestamp => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // Флаг синхронизации для события истории
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

class ChangeTypeConverter extends TypeConverter<ChangeType, String> {
  const ChangeTypeConverter();
  @override
  ChangeType fromSql(String fromDb) => ChangeType.values.firstWhere(
    (e) => e.toString().split('.').last == fromDb,
  );
  @override
  String toSql(ChangeType value) => value.toString().split('.').last;
}

class AccountStateModelConverter
    extends TypeConverter<AccountStateModel, String> {
  const AccountStateModelConverter();
  @override
  AccountStateModel fromSql(String fromDb) =>
      AccountStateModel.fromJson(json.decode(fromDb) as Map<String, dynamic>);
  @override
  String toSql(AccountStateModel value) => json.encode(value.toJson());
}

part of '../database.dart';

@DataClassName('CategoryDbModel')
class CategoryTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get emoji => text().withDefault(const Constant('💰'))();
  BoolColumn get isIncome => boolean().withDefault(const Constant(false))();
}

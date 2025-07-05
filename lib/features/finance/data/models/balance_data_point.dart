class BalanceDataPoint {
  final DateTime date;
  final double amount; // Баланс на эту дату

  BalanceDataPoint({required this.date, required this.amount});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BalanceDataPoint &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          amount == other.amount;

  @override
  int get hashCode => date.hashCode ^ amount.hashCode;
}

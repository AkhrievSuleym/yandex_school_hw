class ApiEndpoints {
  // Account Endpoints
  static const String accounts = '/accounts';
  static const String accountHistory = '/accounts/{id}/history';

  // Category Endpoints
  static const String categories = '/categories';
  static const String categoriesByType = '/categories/type/{isIncome}';

  // Transaction Endpoints
  static const String transactions = '/transactions';
  static const String transactionById =
      '/transactions/{id}'; // Для GET, PUT, DELETE одной транзакции
  static const String transactionsByAccountPeriod =
      '/transactions/account/{accountId}/period';
}

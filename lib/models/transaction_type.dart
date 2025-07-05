// models/transaction_type.dart
enum TransactionType {
  income,
  expense,
}

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.income:
        return 'Pemasukan';
      case TransactionType.expense:
        return 'Pengeluaran';
    }
  }

  bool get isIncome => this == TransactionType.income;
  bool get isExpense => this == TransactionType.expense;
}

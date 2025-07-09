// models/financial_summary.dart
import 'package:expense_tracker/models/transaction_type.dart';
import 'package:expense_tracker/models/transactions.dart';

class FinancialSummary {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, double> categoryBreakdown;

  FinancialSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.startDate,
    required this.endDate,
    required this.categoryBreakdown,
  });

  factory FinancialSummary.fromTransactions(
    List<Transaction> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    final filteredTransactions = transactions
        .where((t) =>
            (t.date.isAfter(startDate) || t.date.isAtSameMomentAs(startDate)) &&
            (t.date.isBefore(endDate) || t.date.isAtSameMomentAs(endDate)))
        .toList();

    double totalIncome = 0;
    double totalExpense = 0;
    Map<String, double> categoryBreakdown = {};

    for (final transaction in filteredTransactions) {
      if (transaction.type == TransactionType.income) {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }

      // Breakdown per kategori
      if (categoryBreakdown.containsKey(transaction.category)) {
        categoryBreakdown[transaction.category] =
            categoryBreakdown[transaction.category]! + transaction.amount;
      } else {
        categoryBreakdown[transaction.category] = transaction.amount;
      }
    }

    return FinancialSummary(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: totalIncome - totalExpense,
      startDate: startDate,
      endDate: endDate,
      categoryBreakdown: categoryBreakdown,
    );
  }

  @override
  String toString() {
    return 'FinancialSummary(totalIncome: $totalIncome, totalExpense: $totalExpense, balance: $balance, startDate: $startDate, endDate: $endDate)';
  }
}

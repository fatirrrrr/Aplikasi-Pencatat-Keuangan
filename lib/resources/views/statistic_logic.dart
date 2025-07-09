import 'package:flutter/material.dart';
import 'package:expense_tracker/models/transactions.dart';
import 'package:expense_tracker/models/transaction_type.dart';

// Kelas untuk menyimpan hasil kalkulasi per kategori
class CategorySummary {
  final String categoryName;
  final double totalAmount;
  final double percentage;
  final Color color;

  CategorySummary({
    required this.categoryName,
    required this.totalAmount,
    required this.percentage,
    required this.color,
  });
}

// Kelas utama untuk mengolah data
class FinancialSummary {
  final double totalIncome;
  final double totalExpense;
  final double remainingBalance;
  final List<CategorySummary> expenseSummaries;

  FinancialSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.remainingBalance,
    required this.expenseSummaries,
  });

  // Fungsi utama untuk memproses daftar transaksi
  factory FinancialSummary.fromTransactions(List<Transaction> transactions) {
    // 1. Hitung total pemasukan dan pengeluaran
    double income = 0;
    double expense = 0;
    final Map<String, double> expenseByCategory = {};

    for (var trx in transactions) {
      if (trx.type == TransactionType.income) {
        income += trx.amount;
      } else {
        expense += trx.amount;
        // Jumlahkan pengeluaran berdasarkan kategori
        expenseByCategory.update(trx.category, (value) => value + trx.amount, ifAbsent: () => trx.amount);
      }
    }

    // Daftar warna untuk setiap kategori
    final List<Color> chartColors = [
      Colors.green, Colors.orange, Colors.blue, Colors.purple,
      Colors.red, Colors.teal, Colors.pink, Colors.amber,
    ];
    int colorIndex = 0;

    // 2. Buat ringkasan untuk Sisa Saldo
    final double balance = income - expense;
    final List<CategorySummary> summaries = [];
    
    // Total basis untuk persentase (bisa dari total pemasukan atau budget)
    // Di sini kita gunakan total pemasukan. Jika pemasukan 0, gunakan total pengeluaran.
    final double percentageBase = income > 0 ? income : expense;

    if (percentageBase > 0) {
      // Tambahkan Sisa Saldo sebagai item pertama
      summaries.add(CategorySummary(
        categoryName: 'Sisa Saldo',
        totalAmount: balance,
        percentage: (balance / percentageBase) * 100,
        color: Colors.green.shade400, // Warna khusus untuk sisa saldo
      ));

      // 3. Proses setiap kategori pengeluaran
      expenseByCategory.forEach((category, amount) {
        summaries.add(CategorySummary(
          categoryName: category,
          totalAmount: amount,
          percentage: (amount / percentageBase) * 100,
          color: chartColors[colorIndex % chartColors.length], // Ambil warna secara berurutan
        ));
        colorIndex++;
      });
    }

    return FinancialSummary(
      totalIncome: income,
      totalExpense: expense,
      remainingBalance: balance,
      expenseSummaries: summaries,
    );
  }
}
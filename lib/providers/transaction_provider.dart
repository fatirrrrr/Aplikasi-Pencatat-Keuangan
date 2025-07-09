import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Menggunakan alias untuk menghindari konflik nama dengan sqflite
import 'package:expense_tracker/models/transactions.dart' as TransactionsModel;
import 'package:expense_tracker/models/category.dart' as model;
import 'package:expense_tracker/resources/views/statistic_logic.dart';
import 'package:expense_tracker/utils/database_helper.dart';

// Notifier untuk mengelola daftar transaksi
class TransactionNotifier
    extends StateNotifier<List<TransactionsModel.Transaction>> {
  final DatabaseHelper _dbHelper;

  TransactionNotifier(this._dbHelper) : super([]);

  Future<void> loadTransactions() async {
    try {
      state = await _dbHelper.getAllTransactions();
      debugPrint('Berhasil memuat ${state.length} transaksi.');
    } catch (e, stackTrace) {
      debugPrint('Gagal memuat transaksi: $e');
      debugPrint('Stack trace: $stackTrace');
      state = [];
    }
  }

  Future<void> loadTransactionsByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      state = await _dbHelper.getTransactionsByDateRange(startDate, endDate);
    } catch (e) {
      debugPrint('Gagal memuat transaksi: $e');
      debugPrint('Stack Trace: $StackTrace');
    }
  }

  Future<void> addTransaction(TransactionsModel.Transaction transaction) async {
    await _dbHelper.insertTransaction(transaction);
    await loadTransactions();
  }

  Future<void> updateTransaction(
      TransactionsModel.Transaction transaction) async {
    await _dbHelper.updateTransaction(transaction);
    await loadTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await _dbHelper.deleteTransaction(id);
    await loadTransactions();
  }
}

// Provider utama untuk transaksi
final transactionProvider = StateNotifierProvider<TransactionNotifier,
    List<TransactionsModel.Transaction>>((ref) {
  return TransactionNotifier(DatabaseHelper());
});

// Provider untuk bulan yang dipilih di halaman statistik
final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Provider untuk kalkulasi statistik bulanan secara dinamis
final financialSummaryProvider = Provider<FinancialSummary>((ref) {
  final allTransactions = ref.watch(transactionProvider);
  final selectedMonth = ref.watch(selectedMonthProvider);

  final filteredTransactions = allTransactions.where((trx) {
    return trx.date.month == selectedMonth.month &&
        trx.date.year == selectedMonth.year;
  }).toList();

  return FinancialSummary.fromTransactions(filteredTransactions);
});

// Provider untuk memuat semua kategori, digunakan di form tambah data
final categoriesProvider = FutureProvider<List<model.Category>>((ref) async {
  final dbHelper = DatabaseHelper();
  return await dbHelper.getAllCategories();
});

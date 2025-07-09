import 'package:expense_tracker/models/transaction_type.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:expense_tracker/resources/views/add_data_page.dart';
import 'package:expense_tracker/resources/widget/expense_pie_chart.dart';
import 'package:expense_tracker/resources/widget/summary_section.dart';
import 'package:expense_tracker/utils/other_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

// Diubah menjadi ConsumerWidget yang lebih sederhana
class Homepage extends ConsumerWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // initState DIHAPUS. Data sudah dimuat oleh AppLayout.
    // Kita hanya perlu 'mendengarkan' perubahannya di sini.
    final allTransactions = ref.watch(transactionProvider);

    // Kalkulasi data tidak berubah
    double totalPemasukan = 0;
    double totalPengeluaran = 0;
    final Map<String, double> expenseByCategory = {};

    for (final trx in allTransactions) {
      if (trx.type == TransactionType.income) {
        totalPemasukan += trx.amount;
      } else {
        totalPengeluaran += trx.amount;
        expenseByCategory.update(trx.category, (value) => value + trx.amount,
            ifAbsent: () => trx.amount);
      }
    }
    final double saldo = totalPemasukan - totalPengeluaran;

    List<ChartData> getChartData() {
      if (totalPengeluaran == 0) return [];
      final colors = [
        const Color(0xFF1B3B73), const Color(0xFF4A90E2),
        const Color(0xFF7DD3C0), const Color(0xFFFFB347),
        const Color(0xFFFF6B6B), const Color(0xFF45B7D1),
      ];
      int colorIndex = 0;
      return expenseByCategory.entries.map((entry) {
        final percentage = (entry.value / totalPengeluaran) * 100;
        final color = colors[colorIndex % colors.length];
        colorIndex++;
        return ChartData(entry.key, percentage, color);
      }).toList();
    }
    
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    // UI lainnya tidak berubah
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 180,
            width: double.infinity,
            color: const Color(0xFF1B3B73),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Expense Tracker', style: textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Kelola pemasukan & pengeluaranmu dengan mudah', textAlign: TextAlign.center, style: textTheme.titleMedium?.copyWith(color: Colors.white)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.grey.withAlpha(25), spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Saldo Saat Ini', style: textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
                      const SizedBox(height: 8),
                      Text(formatRupiah(saldo), style: textTheme.headlineLarge?.copyWith(color: Colors.grey[800], fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => pushScreenWithoutNavBar(context, const AddDataPage()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: Colors.grey[800],
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('+ Tambah Data'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SummarySection(pemasukan: totalPemasukan, pengeluaran: totalPengeluaran),
                const SizedBox(height: 24),
                ExpensePieChart(dataSource: getChartData()),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
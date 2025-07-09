import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:expense_tracker/providers/transaction_provider.dart'; // Lokasi provider yang kita buat

// Halaman diubah menjadi ConsumerWidget untuk bisa 'mendengarkan' provider
class GraphPage extends ConsumerWidget {
  const GraphPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pindahkan formatter ke sini agar bisa diakses oleh semua method
    final NumberFormat currencyFormatter = NumberFormat.decimalPattern('id_ID');

    return DefaultTabController(
      length: 1, // Jumlah tab: 1
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Statistik Keuangan',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          backgroundColor: Theme.of(context).colorScheme.primary,
          // Menambahkan TabBar di bawah AppBar
          bottom: TabBar(
            labelColor: Theme.of(context).colorScheme.onPrimary,
            unselectedLabelColor:
                Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
            indicatorColor: Theme.of(context).colorScheme.onPrimary,
            tabs: const [
              Tab(text: 'BULANAN'),
              // Tab(text: 'KUSTOM'),
            ],
          ),
        ),
        // Menampilkan konten sesuai tab yang aktif
        body: TabBarView(
          children: [
            // Konten untuk Tab "Bulanan"
            _buildMonthlyView(context, ref, currencyFormatter),

            // Konten untuk Tab "Kustom" (bisa Anda kembangkan lebih lanjut)
            Center(
              child: Text(
                'Tampilan Kustom (segera hadir!)',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Method untuk membangun UI pada tab "Bulanan"
  Widget _buildMonthlyView(
      BuildContext context, WidgetRef ref, NumberFormat formatter) {
    // 'ref.watch' akan secara otomatis membangun ulang widget ini jika data berubah
    final summary = ref.watch(financialSummaryProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);

    // Fungsi untuk mengganti bulan (maju atau mundur)
    void changeMonth(int monthIncrement) {
      ref.read(selectedMonthProvider.notifier).state = DateTime(
        selectedMonth.year,
        selectedMonth.month + monthIncrement,
        1,
      );
    }

    // Tampilan jika tidak ada data untuk bulan yang dipilih
    if (summary.expenseSummaries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => changeMonth(-1)),
                Text(
                  DateFormat('MMMM yyyy', 'id_ID').format(selectedMonth),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => changeMonth(1)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Tidak ada data untuk bulan ini.'),
          ],
        ),
      );
    }

    // Tampilan utama jika ada data
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Widget pemilih bulan
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => changeMonth(-1)),
                Text(
                  DateFormat('MMMM yyyy', 'id_ID').format(selectedMonth),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => changeMonth(1)),
              ],
            ),
            const SizedBox(height: 16),

            // Donut Chart
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 70,
                  sections: summary.expenseSummaries.map((item) {
                    return PieChartSectionData(
                      color: item.color,
                      value: item.percentage,
                      title: '${item.percentage.toStringAsFixed(0)}%',
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Daftar Rincian
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: summary.expenseSummaries.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = summary.expenseSummaries[index];
                return _buildSummaryRow(
                  color: item.color,
                  percentage: item.percentage.toInt(),
                  category: item.categoryName,
                  amount: item.totalAmount,
                  formatter: formatter,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Helper widget untuk membangun satu baris rincian statistik
  Widget _buildSummaryRow({
    required Color color,
    required int percentage,
    required String category,
    required double amount,
    required NumberFormat formatter,
  }) {
    final isSaldo = category == 'Sisa Saldo';

    return Row(
      children: [
        Container(
          width: 50,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            '$percentage%',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: color, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(category,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ),
        Text(
          // Menambahkan format mata uang dan menangani saldo negatif
          isSaldo && amount < 0
              ? '-Rp${formatter.format(amount.abs())}'
              : 'Rp${formatter.format(amount)}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

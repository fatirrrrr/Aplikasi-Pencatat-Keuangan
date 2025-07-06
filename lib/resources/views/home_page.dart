import 'package:expense_tracker/resources/views/add_data_page.dart';
import 'package:expense_tracker/resources/widget/expense_pie_chart.dart';
import 'package:expense_tracker/resources/widget/summary_section.dart';
import 'package:expense_tracker/routes/route.dart';
import 'package:expense_tracker/utils/other_utils.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

// 1. PARENT WIDGET (STATEFUL)
// Bertanggung jawab untuk mengelola state (data).
class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // --- State (Data yang dapat berubah) ---
  double _saldo = 5000000;
  double _totalPemasukan = 3000000;
  double _totalPengeluaran = 650000;

  // fungsi sementara
  void _tambahData() {
    setState(() {
      double pemasukanBaru = 50000; // Contoh pemasukan baru
      _totalPemasukan += pemasukanBaru;

      _saldo = 5000000 + _totalPemasukan - _totalPengeluaran;

      // Uncomment untuk menampilkan notifikasi jika perlu
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       'Berhasil menambah pemasukan: Rp ${pemasukanBaru.toStringAsFixed(0)}',
      //     ),
      //     backgroundColor: Colors.green,
      //   ),
      // );
    });
  }

  @override
  Widget build(BuildContext context) {
    return HomepageView(
      saldo: _saldo,
      totalPemasukan: _totalPemasukan,
      totalPengeluaran: _totalPengeluaran,
      onTambahData: _tambahData,
    );
  }
}

class HomepageView extends StatelessWidget {
  final double saldo;
  final double totalPemasukan;
  final double totalPengeluaran;
  final VoidCallback onTambahData; // Menerima fungsi dari parent

  const HomepageView({
    super.key,
    required this.saldo,
    required this.totalPemasukan,
    required this.totalPengeluaran,
    required this.onTambahData,
  });

  List<ChartData> getChartData() {
    return [
      ChartData('Makan', 35, const Color(0xFF1B3B73)),
      ChartData('Transport', 25, const Color(0xFF4A90E2)),
      ChartData('Belanja', 20, const Color(0xFF7DD3C0)),
      ChartData('Hiburan', 15, const Color(0xFFFFB347)),
      ChartData('Lainnya', 5, const Color(0xFFFF6B6B)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header Section
          Container(
            height: 180,
            width: double.infinity,
            color: const Color(0xFF1B3B73),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Expense Tracker',
                    style: textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kelola pemasukan & pengeluaranmu dengan mudah',
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // Body Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Saldo Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saldo Saat Ini',
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatRupiah(saldo),
                        style: textTheme.headlineLarge?.copyWith(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            pushScreenWithoutNavBar(context, AddDataPage());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.grey[700],
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('+ Tambah Data'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                SummarySection(
                  pemasukan: totalPemasukan,
                  pengeluaran: totalPengeluaran,
                ),

                const SizedBox(height: 24),

                // Pie Chart Section
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

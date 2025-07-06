import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// Model untuk data chart
class ChartData {
  final String category;
  final double value;
  final Color color;

  ChartData(this.category, this.value, this.color);
}

// Widget khusus untuk menampilkan Pie Chart
class ExpensePieChart extends StatelessWidget {
  final List<ChartData> dataSource;
  final String title;

  const ExpensePieChart({
    super.key,
    required this.dataSource,
    this.title = 'Grafik Pengeluaran Bulanan', // Judul default jika tidak diisi
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1), // Menggunakan withOpacity
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
            title, // Menggunakan judul dari parameter
            style: textTheme.titleLarge?.copyWith(
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: SfCircularChart(
              series: <CircularSeries>[
                PieSeries<ChartData, String>(
                  dataSource: dataSource, // Menggunakan data dari parameter
                  xValueMapper: (ChartData data, _) => data.category,
                  yValueMapper: (ChartData data, _) => data.value,
                  pointColorMapper: (ChartData data, _) => data.color,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.outside,
                    textStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  enableTooltip: true,
                  explode: false, // Sesuai kode awal
                ),
              ],
              legend: const Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                overflowMode: LegendItemOverflowMode.wrap,
                textStyle: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
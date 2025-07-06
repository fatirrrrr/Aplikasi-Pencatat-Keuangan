import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl untuk formatting
import 'income_expense_card.dart';

class SummarySection extends StatelessWidget {
  final double pemasukan;
  final double pengeluaran;

  const SummarySection({
    super.key,
    required this.pemasukan,
    required this.pengeluaran,
  });

  // Helper untuk format angka ke Rupiah
  String _formatRupiah(double amount) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Pemasukan Card
        IncomeExpenseCard(
          title: 'Pemasukan',
          amount: _formatRupiah(pemasukan), // Gunakan data dari parameter
          iconData: Icons.arrow_downward,
          iconColor: Colors.green[600]!,
          backgroundColor: Colors.green[100]!,
        ),

        const SizedBox(width: 16),

        // Pengeluaran Card
        IncomeExpenseCard(
          title: 'Pengeluaran',
          amount: _formatRupiah(pengeluaran), // Gunakan data dari parameter
          iconData: Icons.arrow_upward,
          iconColor: Colors.red[600]!,
          backgroundColor: Colors.red[100]!,
        ),
      ],
    );
  }
}
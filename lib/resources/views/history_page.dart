import 'package:expense_tracker/utils/export_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // BARU: import Riverpod
import 'package:expense_tracker/models/transactions.dart';
import 'package:expense_tracker/models/transaction_type.dart';
import 'package:intl/intl.dart';

// BARU: import provider Anda
import 'package:expense_tracker/providers/transaction_provider.dart';

// DIUBAH: Menjadi ConsumerStatefulWidget
class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

// DIUBAH: Menjadi ConsumerState<HistoryPage>
class _HistoryPageState extends ConsumerState<HistoryPage> {
  // State lokal untuk filter UI (Pemasukan/Pengeluaran) tetap di sini
  TransactionType _selectedType = TransactionType.expense;
  final ExportService _exportService = ExportService();

  // DIHAPUS: Semua state manual seperti _databaseHelper, _transactions, _isLoading, initState, dan _loadTransactions
  // sekarang dikelola oleh Riverpod.

  void _showDeleteConfirmation(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: Text(
            'Apakah Anda yakin ingin menghapus transaksi "${transaction.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // DIUBAH: Memanggil method delete pada notifier provider.
              // UI akan otomatis update setelah ini karena kita menggunakan ref.watch di build.
              ref
                  .read(transactionProvider.notifier)
                  .deleteTransaction(transaction.id!);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transaksi berhasil dihapus')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _export(String format, List<Transaction> allTransactions) {
    if (allTransactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data untuk diekspor')),
      );
      return;
    }

    final startDate = allTransactions
        .map((t) => t.date)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final endDate = allTransactions
        .map((t) => t.date)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    if (format == 'pdf') {
      _exportService.exportToPDF(
        context,
        transactions: allTransactions,
        startDate: startDate,
        endDate: endDate,
      );
    } else if (format == 'excel') {
      _exportService.exportToExcel(
        context,
        transactions: allTransactions,
        startDate: startDate,
        endDate: endDate,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // "Mendengarkan" provider. `allTransactions` akan selalu berisi data terbaru.
    final allTransactions = ref.watch(transactionProvider);

    // Logika filter tetap sama, tapi sekarang menggunakan data dari provider
    // agar data selalu update realtime
    final filteredTransactions =
        allTransactions.where((t) => t.type == _selectedType).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        actions: [
          if (allTransactions.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) => _export(value, allTransactions),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'pdf',
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Export PDF'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'excel',
                  child: Row(
                    children: [
                      Icon(Icons.table_chart, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Export Excel'),
                    ],
                  ),
                ),
              ],
              icon: const Icon(Icons.download),
            ),
        ],
      ),
      body: Column(
        children: [
          // Widget filter tidak ada perubahan
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        setState(() => _selectedType = TransactionType.income),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedType == TransactionType.income
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surface,
                      foregroundColor: _selectedType == TransactionType.income
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                    child: const Text('Pemasukan'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        setState(() => _selectedType = TransactionType.expense),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedType == TransactionType.expense
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surface,
                      foregroundColor: _selectedType == TransactionType.expense
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                    child: const Text('Pengeluaran'),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            // kondisi jika filteren transaction kosong
            child: filteredTransactions.isEmpty
                ? Center(
                    // Tampilan jika tidak ada data
                    child: Text(
                      'Tidak ada transaksi ${_selectedType.displayName.toLowerCase()}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                  )
                : RefreshIndicator(
                    // kondisi jika filtered transaction ada
                    // onRefresh memanggil method loadTransactions pada notifier
                    onRefresh: () => ref
                        .read(transactionProvider.notifier)
                        .loadTransactions(),
                    child: ListView.builder(
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = filteredTransactions[index];
                        // Widget Card dan ListTile tidak perlu diubah
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                                color: Colors.grey.shade200, width: 1),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  transaction.type == TransactionType.income
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                              child: Icon(
                                transaction.type == TransactionType.income
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color:
                                    transaction.type == TransactionType.income
                                        ? Colors.green
                                        : Colors.red,
                              ),
                            ),
                            title: Text(transaction.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(transaction.category),
                                Text(DateFormat('dd/MM/yyyy')
                                    .format(transaction.date)),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Rp ${NumberFormat('#,##0', 'id_ID').format(transaction.amount)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: transaction.type ==
                                            TransactionType.income
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _showDeleteConfirmation(transaction),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

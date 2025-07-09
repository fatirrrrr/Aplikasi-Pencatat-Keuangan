import 'package:flutter/material.dart';
import 'package:expense_tracker/models/transactions.dart';
import 'package:expense_tracker/models/transaction_type.dart';
import 'package:expense_tracker/utils/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Transaction> _transactions = [];
  TransactionType _selectedType = TransactionType.expense;
  bool _isLoading = true;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final transactions = await _databaseHelper.getAllTransactions();
      if (mounted) {
        setState(() {
          _transactions = transactions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Error loading transactions: $e');
      }
    }
  }

  List<Transaction> get _filteredTransactions {
    return _transactions
        .where((transaction) => transaction.type == _selectedType)
        .toList();
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _deleteTransaction(int id) async {
    try {
      await _databaseHelper.deleteTransaction(id);
      await _loadTransactions();
      _showSnackBar('Transaksi berhasil dihapus');
    } catch (e) {
      _showSnackBar('Error deleting transaction: $e');
    }
  }

  void _showDeleteConfirmation(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: Text(
          'Apakah Anda yakin ingin menghapus transaksi "${transaction.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteTransaction(transaction.id!);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.manageExternalStorage.status;
      if (!status.isGranted) {
        status = await Permission.manageExternalStorage.request();
        if (status.isDenied || status.isPermanentlyDenied) {
          status = await Permission.storage.request();
        }
      }
      return status.isGranted;
    }
    return true;
  }

  Future<void> _exportPDF() async {
    await _performExport('PDF', _generatePDF);
  }

  Future<void> _exportExcel() async {
    await _performExport('Excel', _generateExcel);
  }

  Future<void> _performExport(
    String type,
    Future<String> Function() exportFunction,
  ) async {
    // Prevent multiple exports
    if (_isExporting) return;

    // Set exporting state
    setState(() => _isExporting = true);

    try {
      // Check permission
      if (!await _requestPermission()) {
        _showSnackBar('Permission denied');
        return;
      }

      // Export file
      final filePath = await exportFunction();

      // Show success dialog
      if (mounted) {
        _showExportSuccessDialog(filePath, type);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error exporting $type: $e');
      }
    } finally {
      // Always reset exporting state
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _showExportSuccessDialog(String filePath, String fileType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Berhasil'),
        content: Text('File $fileType telah disimpan di:\n$filePath'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              OpenFile.open(filePath);
            },
            child: const Text('Buka File'),
          ),
        ],
      ),
    );
  }

  Future<String> _generatePDF() async {
    final pdf = pw.Document();
    final transactions = _filteredTransactions;
    final typeText = _selectedType == TransactionType.income
        ? 'Pemasukan'
        : 'Pengeluaran';
    final total = transactions.fold(0.0, (sum, t) => sum + t.amount);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Laporan Transaksi $typeText',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Tanggal Export: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
            ),
            pw.SizedBox(height: 20),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(border: pw.Border.all()),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Transaksi: ${transactions.length}'),
                  pw.Text(
                    'Total: Rp ${NumberFormat('#,##0', 'id_ID').format(total)}',
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Judul', 'Kategori', 'Tanggal', 'Nominal'],
              data: transactions
                  .map(
                    (t) => [
                      t.title,
                      t.category,
                      DateFormat('dd/MM/yyyy').format(t.date),
                      'Rp ${NumberFormat('#,##0', 'id_ID').format(t.amount)}',
                    ],
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        'Laporan_${typeText}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  Future<String> _generateExcel() async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];
    final transactions = _filteredTransactions;
    final typeText = _selectedType == TransactionType.income
        ? 'Pemasukan'
        : 'Pengeluaran';
    final total = transactions.fold(0.0, (sum, t) => sum + t.amount);

    // Headers
    sheet.cell(CellIndex.indexByString("A1")).value = TextCellValue(
      'Laporan Transaksi $typeText',
    );
    sheet.cell(CellIndex.indexByString("A2")).value = TextCellValue(
      'Tanggal Export: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
    );
    sheet.cell(CellIndex.indexByString("A3")).value = TextCellValue(
      'Total Transaksi: ${transactions.length}',
    );
    sheet.cell(CellIndex.indexByString("A4")).value = TextCellValue(
      'Total: Rp ${NumberFormat('#,##0', 'id_ID').format(total)}',
    );

    // Table headers
    sheet.cell(CellIndex.indexByString("A6")).value = TextCellValue('Judul');
    sheet.cell(CellIndex.indexByString("B6")).value = TextCellValue('Kategori');
    sheet.cell(CellIndex.indexByString("C6")).value = TextCellValue('Tanggal');
    sheet.cell(CellIndex.indexByString("D6")).value = TextCellValue('Nominal');

    // Data
    for (int i = 0; i < transactions.length; i++) {
      final t = transactions[i];
      final row = i + 7;
      sheet.cell(CellIndex.indexByString("A$row")).value = TextCellValue(
        t.title,
      );
      sheet.cell(CellIndex.indexByString("B$row")).value = TextCellValue(
        t.category,
      );
      sheet.cell(CellIndex.indexByString("C$row")).value = TextCellValue(
        DateFormat('dd/MM/yyyy').format(t.date),
      );
      sheet.cell(CellIndex.indexByString("D$row")).value = DoubleCellValue(
        t.amount,
      );
    }

    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        'Laporan_${typeText}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(excel.save()!);
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        actions: [
          PopupMenuButton<String>(
            enabled: !_isExporting,
            onSelected: (value) {
              if (value == 'pdf') {
                _exportPDF();
              } else if (value == 'excel') {
                _exportExcel();
              }
            },
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
            icon: Icon(
              Icons.download,
              color: _isExporting ? Colors.grey : null,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isExporting
                        ? null
                        : () => setState(
                            () => _selectedType = TransactionType.income,
                          ),
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
                    onPressed: _isExporting
                        ? null
                        : () => setState(
                            () => _selectedType = TransactionType.expense,
                          ),
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

          // Export Status
          if (_isExporting)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Sedang mengekspor...'),
                ],
              ),
            ),

          // Transaction List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTransactions.isEmpty
                ? _buildEmptyState()
                : _buildTransactionList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada transaksi ${_selectedType.displayName.toLowerCase()}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: ListView.builder(
        itemCount: _filteredTransactions.length,
        itemBuilder: (context, index) {
          final transaction = _filteredTransactions[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: transaction.type == TransactionType.income
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                child: Icon(
                  transaction.type == TransactionType.income
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  color: transaction.type == TransactionType.income
                      ? Colors.green
                      : Colors.red,
                ),
              ),
              title: Text(transaction.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.category),
                  Text(
                    DateFormat('dd/MM/yyyy').format(transaction.date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Rp ${NumberFormat('#,##0', 'id_ID').format(transaction.amount)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: transaction.type == TransactionType.income
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: _isExporting
                        ? null
                        : () => _showDeleteConfirmation(transaction),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

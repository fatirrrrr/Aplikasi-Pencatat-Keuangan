import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:expense_tracker/models/transactions.dart' as TransactionsModel;
import 'package:expense_tracker/models/financials_summary.dart';

class ExportService {
  // Export to PDF
  Future<void> exportToPDF(
    BuildContext context, {
    required List<TransactionsModel.Transaction> transactions,
    required DateTime startDate,
    required DateTime endDate,
    bool shouldShare = false, // Parameter baru untuk mengontrol share
  }) async {
    // Tampilkan dialog loading di awal
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      if (transactions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada data transaksi untuk diekspor.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // 1. Buat ringkasan dan dokumen PDF
      final summary =
          FinancialSummary.fromTransactions(transactions, startDate, endDate);
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text('Laporan Keuangan',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                  'Periode: ${_formatDate(startDate)} - ${_formatDate(endDate)}',
                  style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 20),
              _buildSummaryPdf(summary),
              pw.SizedBox(height: 30),
              pw.Text('Detail Transaksi',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              _buildTransactionsTablePdf(transactions),
            ];
          },
        ),
      );

      // 2. Simpan file ke Downloads directory
      final Directory? downloadsDirectory = await getExternalStorageDirectory();
      final String downloadsPath = '${downloadsDirectory!.path}/Download';
      final Directory downloadsDir = Directory(downloadsPath);

      // Buat folder Download jika belum ada
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final String fileName =
          'laporan_keuangan_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('$downloadsPath/$fileName');
      await file.writeAsBytes(await pdf.save());

      // 3. Bagikan file hanya jika diminta
      if (shouldShare) {
        await Share.shareXFiles([XFile(file.path)],
            text: 'Laporan Keuangan Anda');
      }

      // 4. Tampilkan dialog pilihan
      _showExportSuccessDialog(context, file.path, 'PDF', fileName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengekspor PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  // Export to Excel
  Future<void> exportToExcel(
    BuildContext context, {
    required List<TransactionsModel.Transaction> transactions,
    required DateTime startDate,
    required DateTime endDate,
    bool shouldShare = false, // Parameter baru untuk mengontrol share
  }) async {
    // Tampilkan dialog loading di awal
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      if (transactions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada data transaksi untuk diekspor.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // 1. Buat ringkasan dan workbook Excel
      final summary =
          FinancialSummary.fromTransactions(transactions, startDate, endDate);
      final excel = Excel.createExcel();
      excel.delete('Sheet1'); // Hapus sheet default

      // Sheet Ringkasan
      final summarySheet = excel['Ringkasan'];
      summarySheet.cell(CellIndex.indexByString('A1')).value =
          TextCellValue('Ringkasan Keuangan');
      summarySheet.cell(CellIndex.indexByString('A2')).value = TextCellValue(
          'Periode: ${_formatDate(startDate)} - ${_formatDate(endDate)}');
      summarySheet.cell(CellIndex.indexByString('A4')).value =
          TextCellValue('Total Pemasukan');
      summarySheet.cell(CellIndex.indexByString('B4')).value =
          DoubleCellValue(summary.totalIncome);
      summarySheet.cell(CellIndex.indexByString('A5')).value =
          TextCellValue('Total Pengeluaran');
      summarySheet.cell(CellIndex.indexByString('B5')).value =
          DoubleCellValue(summary.totalExpense);
      summarySheet.cell(CellIndex.indexByString('A6')).value =
          TextCellValue('Saldo Akhir');
      summarySheet.cell(CellIndex.indexByString('B6')).value =
          DoubleCellValue(summary.balance);

      // Sheet Transaksi
      final transactionsSheet = excel['Transaksi'];
      transactionsSheet.appendRow([
        TextCellValue('Tanggal'),
        TextCellValue('Judul'),
        TextCellValue('Deskripsi'),
        TextCellValue('Kategori'),
        TextCellValue('Tipe'),
        TextCellValue('Jumlah'),
      ]);
      for (final transaction in transactions) {
        transactionsSheet.appendRow([
          TextCellValue(_formatDate(transaction.date)),
          TextCellValue(transaction.title),
          TextCellValue(transaction.description ?? ''),
          TextCellValue(transaction.category),
          TextCellValue(transaction.type.name.toUpperCase()),
          DoubleCellValue(transaction.amount),
        ]);
      }

      // Sheet Rincian Kategori
      final categorySheet = excel['Rincian Kategori'];
      categorySheet
          .appendRow([TextCellValue('Kategori'), TextCellValue('Jumlah')]);
      summary.categoryBreakdown.forEach((category, amount) {
        categorySheet
            .appendRow([TextCellValue(category), DoubleCellValue(amount)]);
      });

      // 2. Simpan file Excel ke Downloads directory
      final fileBytes = excel.encode();
      if (fileBytes == null) {
        throw Exception("Gagal membuat file Excel.");
      }

      final Directory? downloadsDirectory = await getExternalStorageDirectory();
      final String downloadsPath = '${downloadsDirectory!.path}/Download';
      final Directory downloadsDir = Directory(downloadsPath);

      // Buat folder Download jika belum ada
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final String fileName =
          'laporan_keuangan_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final file = File('$downloadsPath/$fileName');
      await file.writeAsBytes(fileBytes);

      // 3. Bagikan file hanya jika diminta
      if (shouldShare) {
        await Share.shareXFiles([XFile(file.path)],
            text: 'Laporan Keuangan Anda');
      }

      // 4. Tampilkan dialog pilihan
      _showExportSuccessDialog(context, file.path, 'Excel', fileName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengekspor Excel: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  // Dialog untuk pilihan setelah export berhasil
  void _showExportSuccessDialog(
      BuildContext context, String filePath, String fileType, String fileName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$fileType Berhasil Disimpan'),
          content: Text(
              'File $fileName berhasil disimpan.\n\nApa yang ingin Anda lakukan?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Tampilkan snackbar sukses
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$fileType berhasil disimpan!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Tutup'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  final result = await OpenFile.open(filePath);
                  if (result.type != ResultType.done) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Tidak dapat membuka file: ${result.message}'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal membuka file: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Buka File'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await shareExistingFile(filePath, 'Laporan Keuangan Anda');
              },
              child: const Text('Share'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi terpisah untuk share file yang sudah ada
  Future<void> shareExistingFile(String filePath, String text) async {
    await Share.shareXFiles([XFile(filePath)], text: text);
  }

  // Helper methods untuk format
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  // Widget builder untuk ringkasan PDF
  pw.Widget _buildSummaryPdf(FinancialSummary summary) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Ringkasan',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total Pemasukan:'),
              pw.Text('Rp ${_formatCurrency(summary.totalIncome)}',
                  style: const pw.TextStyle(color: PdfColors.green)),
            ],
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total Pengeluaran:'),
              pw.Text('Rp ${_formatCurrency(summary.totalExpense)}',
                  style: const pw.TextStyle(color: PdfColors.red)),
            ],
          ),
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Saldo Akhir:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(
                'Rp ${_formatCurrency(summary.balance)}',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: summary.balance >= 0 ? PdfColors.green : PdfColors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget builder untuk tabel transaksi PDF
  pw.Widget _buildTransactionsTablePdf(
      List<TransactionsModel.Transaction> transactions) {
    return pw.Table.fromTextArray(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      headerStyle:
          pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(8),
      headers: ['Tanggal', 'Judul', 'Kategori', 'Tipe', 'Jumlah'],
      data: transactions
          .map((tr) => [
                _formatDate(tr.date),
                tr.title,
                tr.category,
                tr.type.name.toUpperCase(),
                'Rp ${_formatCurrency(tr.amount)}',
              ])
          .toList(),
    );
  }
}

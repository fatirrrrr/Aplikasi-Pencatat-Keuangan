// lib/resources/views/test_page.dart

import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TestPage extends ConsumerStatefulWidget {
  const TestPage({super.key});

  @override
  ConsumerState<TestPage> createState() => _TestPageState();
}

class _TestPageState extends ConsumerState<TestPage> {
  @override
  void initState() {
    super.initState();
    // Memanggil pemuatan data dari sini untuk tes
    Future.microtask(
        () => ref.read(transactionProvider.notifier).loadTransactions());
  }

  @override
  Widget build(BuildContext context) {
    // Kita 'watch' kedua provider utama
    final transactions = ref.watch(transactionProvider);
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Halaman Tes Debugging"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: categories.when(
          loading: () => const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Memuat data kategori..."),
            ],
          ),
          error: (err, stack) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "GAGAL MEMUAT DATA:\n\n$err",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
          data: (categoryData) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 20),
              const Text(
                "Provider Berhasil Dimuat!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Jumlah Transaksi: ${transactions.length}",
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                "Jumlah Kategori: ${categoryData.length}",
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
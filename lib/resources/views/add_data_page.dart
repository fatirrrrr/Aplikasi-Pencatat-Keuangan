import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/category.dart' as model;
import '../../models/transaction_type.dart';
import '../../models/transactions.dart';
import '../../providers/transaction_provider.dart';

class AddDataPage extends ConsumerStatefulWidget {
  const AddDataPage({super.key});

  @override
  ConsumerState<AddDataPage> createState() => _AddDataPageState();
}

class _AddDataPageState extends ConsumerState<AddDataPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _dateController = TextEditingController();
  
  TransactionType _selectedType = TransactionType.expense;
  model.Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _saveTransaction() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      final newTransaction = Transaction(
        title: _descController.text.isEmpty ? _selectedCategory!.name : _descController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        type: _selectedType,
        category: _selectedCategory!.name,
        description: _descController.text,
      );
      
      await ref.read(transactionProvider.notifier).addTransaction(newTransaction);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil disimpan'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsyncValue = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Transaksi')),
      body: categoriesAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Gagal memuat kategori: $err')),
        data: (allCategories) {
          final filteredCategories = allCategories
              .where((cat) => cat.type == _selectedType)
              .toList();
          
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                DropdownButtonFormField<TransactionType>(
                  value: _selectedType,
                  items: const [
                    DropdownMenuItem(value: TransactionType.expense, child: Text('Pengeluaran')),
                    DropdownMenuItem(value: TransactionType.income, child: Text('Pemasukan')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                      _selectedCategory = null; 
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Jenis Transaksi', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<model.Category>(
                  value: _selectedCategory,
                  hint: const Text('Pilih Kategori'),
                  decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                  items: filteredCategories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat.name));
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedCategory = value),
                  validator: (value) => value == null ? 'Kategori wajib diisi' : null,
                ),
                
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Jumlah', border: OutlineInputBorder(), prefixText: 'Rp '),
                  keyboardType: TextInputType.number,
                  validator: (value) => (value == null || value.isEmpty) ? 'Jumlah wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Tanggal', border: OutlineInputBorder()),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _selectedDate = pickedDate;
                        _dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Keterangan (Opsional)', border: OutlineInputBorder()),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _saveTransaction,
          child: const Text('Simpan Transaksi'),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/database_helper.dart';
import '../../models/transactions.dart';
import '../../models/category.dart';
import 'package:expense_tracker/models/transaction_type.dart';

class AddDataPage extends StatefulWidget {
  const AddDataPage({super.key});

  @override
  State<AddDataPage> createState() => _AddDataPageState();
}

class _AddDataPageState extends State<AddDataPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;

  String? _selectedType;
  String? _selectedCategory;
  bool _isLoading = false;
  bool _isLoadingCategories = true;

  final List<String> _types = ['Pemasukan', 'Pengeluaran'];
  List<Category> _allCategories = [];
  List<Category> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await DatabaseHelper().getAllCategories();
      setState(() {
        _allCategories = categories;
        _isLoadingCategories = false;
      });
      _filterCategories();
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
      _showErrorMessage('Error loading categories: $e');
    }
  }

  void _filterCategories() {
    if (_selectedType == null) {
      setState(() {
        _filteredCategories = [];
      });
      return;
    }

    final transactionType = _selectedType == 'Pemasukan'
        ? TransactionType.income
        : TransactionType.expense;

    setState(() {
      _filteredCategories = _allCategories
          .where((category) => category.type == transactionType)
          .toList();

      // Reset selected category if it's not in filtered list
      if (_selectedCategory != null &&
          !_filteredCategories.any((cat) => cat.name == _selectedCategory)) {
        _selectedCategory = null;
      }
    });
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _amountController.clear();
    _descController.clear();
    _dateController.clear();
    setState(() {
      _selectedType = null;
      _selectedCategory = null;
      _selectedDate = null;
      _filteredCategories = [];
    });
  }

  void _saveTransaction() async {
    // Validasi manual untuk semua field
    if (_selectedType == null) {
      _showErrorMessage('Pilih jenis transaksi terlebih dahulu');
      return;
    }

    if (_selectedCategory == null) {
      _showErrorMessage('Pilih kategori terlebih dahulu');
      return;
    }

    if (_selectedDate == null) {
      _showErrorMessage('Pilih tanggal terlebih dahulu');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      _showErrorMessage('Lengkapi semua input yang diperlukan');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final title = '${_selectedCategory!} - Rp ${_amountController.text}';
      final newTransaction = Transaction(
        id: null,
        title: title,
        type: _selectedType == 'Pemasukan'
            ? TransactionType.income
            : TransactionType.expense,
        category: _selectedCategory!,
        amount: double.parse(_amountController.text),
        date: _selectedDate!,
        description: _descController.text,
      );

      await DatabaseHelper().insertTransaction(newTransaction);

      if (mounted) {
        _showSuccessMessage('Transaksi berhasil disimpan');
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Gagal menyimpan transaksi: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Transaksi',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Dropdown Jenis Transaksi
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Jenis Transaksi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sync_alt),
                ),
                items: _types.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                    _selectedCategory =
                        null; // Reset kategori ketika jenis berubah
                  });
                  _filterCategories();
                },
                validator: (value) =>
                    value == null ? 'Pilih jenis transaksi' : null,
              ),
              const SizedBox(height: 20),

              // Dropdown Kategori - PERBAIKAN UTAMA
              DropdownButtonFormField<String>(
                key: ValueKey(
                  'category_dropdown_$_selectedType',
                ), // Key unik untuk rebuild
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.local_offer),
                  suffixIcon: _isLoadingCategories
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                ),
                items: _buildCategoryDropdownItems(),
                onChanged: _getCategoryOnChanged(),
                validator: (value) => value == null ? 'Pilih kategori' : null,
                hint: _getCategoryHint(),
                isExpanded: true, // Memastikan dropdown menggunakan lebar penuh
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                  hintText: 'Rp 0',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Masukkan jumlah';
                  if (double.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Jumlah harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: _pickDate,
                decoration: InputDecoration(
                  labelText: 'Tanggal & Waktu',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_today),
                  hintText: 'dd/mm/yyyy',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.date_range),
                    onPressed: _pickDate,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Pilih tanggal';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _descController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Keterangan',
                  hintText: 'Contoh: Beli pulsa, uang jajan',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Icon(Icons.chat_bubble_outline),
                  ),
                  prefixIconConstraints: BoxConstraints(
                    minWidth: 40,
                    minHeight: 0,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveTransaction,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A2F55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Simpan Transaksi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // Helper method untuk membangun dropdown items
  List<DropdownMenuItem<String>>? _buildCategoryDropdownItems() {
    if (_isLoadingCategories || _filteredCategories.isEmpty) {
      return [];
    }

    return _filteredCategories.map((category) {
      return DropdownMenuItem<String>(
        value: category.name,
        child: Row(
          children: [
            Text(category.icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(category.name, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      );
    }).toList();
  }

  // Helper method untuk menentukan onChanged callback
  ValueChanged<String?>? _getCategoryOnChanged() {
    if (_isLoadingCategories || _filteredCategories.isEmpty) {
      return null;
    }

    return (String? value) {
      setState(() {
        _selectedCategory = value;
      });
    };
  }

  // Helper method untuk menentukan hint text
  Widget _getCategoryHint() {
    if (_selectedType == null) {
      return const Text('Pilih jenis transaksi dulu');
    }
    if (_isLoadingCategories) {
      return const Text('Loading...');
    }
    if (_filteredCategories.isEmpty) {
      return const Text('Tidak ada kategori tersedia');
    }
    return const Text('Pilih kategori');
  }
}

// utils/default_categories.dart
import 'package:expense_tracker/models/category.dart';
import 'package:expense_tracker/models/transaction_type.dart';

class DefaultCategories {
  static List<Category> get expenseCategories => [
    Category(
      name: 'Makanan',
      icon: '🍽️',
      color: '#FF6B6B',
      type: TransactionType.expense,
    ),
    Category(
      name: 'Transportasi',
      icon: '🚗',
      color: '#4ECDC4',
      type: TransactionType.expense,
    ),
    Category(
      name: 'Belanja',
      icon: '🛒',
      color: '#45B7D1',
      type: TransactionType.expense,
    ),
    Category(
      name: 'Hiburan',
      icon: '🎬',
      color: '#FFA07A',
      type: TransactionType.expense,
    ),
    Category(
      name: 'Kesehatan',
      icon: '💊',
      color: '#98D8C8',
      type: TransactionType.expense,
    ),
    Category(
      name: 'Tagihan',
      icon: '💡',
      color: '#F7DC6F',
      type: TransactionType.expense,
    ),
    Category(
      name: 'Lainnya',
      icon: '📦',
      color: '#BB8FCE',
      type: TransactionType.expense,
    ),
  ];

  static List<Category> get incomeCategories => [
    Category(
      name: 'Gaji',
      icon: '💰',
      color: '#2ECC71',
      type: TransactionType.income,
    ),
    Category(
      name: 'Freelance',
      icon: '💻',
      color: '#3498DB',
      type: TransactionType.income,
    ),
    Category(
      name: 'Investasi',
      icon: '📈',
      color: '#E74C3C',
      type: TransactionType.income,
    ),
    Category(
      name: 'Bonus',
      icon: '🎁',
      color: '#F39C12',
      type: TransactionType.income,
    ),
    Category(
      name: 'Lainnya',
      icon: '💸',
      color: '#9B59B6',
      type: TransactionType.income,
    ),
  ];

  static List<Category> get allCategories => [
    ...expenseCategories,
    ...incomeCategories,
  ];
}
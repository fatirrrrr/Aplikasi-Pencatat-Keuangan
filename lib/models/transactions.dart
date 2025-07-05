import 'package:expense_tracker/models/transaction_type.dart';

class Transaction {
  final int? id; // Changed to int for SQLite auto-increment
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String category;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    this.description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }): createdAt = createdAt ?? DateTime.now(),
      updatedAt = updatedAt ?? DateTime.now();

  // Factory constructor untuk membuat instance dari Map (SQLite)
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.expense,
      ),
      category: map['category'] as String? ?? '',
      description: map['description'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  // Method untuk mengkonversi ke Map (SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'type': type.name,
      'category': category,
      'description': description,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Method untuk insert (tanpa id)
  Map<String, dynamic> toMapForInsert() {
    return {
      'title': title,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'type': type.name,
      'category': category,
      'description': description,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Method copyWith untuk membuat salinan dengan perubahan
  Transaction copyWith({
    int? id,
    String? title,
    double? amount,
    DateTime? date,
    TransactionType? type,
    String? category,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Static method untuk membuat tabel SQL
  static String get createTableQuery => '''
    CREATE TABLE transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      amount REAL NOT NULL,
      date INTEGER NOT NULL,
      type TEXT NOT NULL,
      category TEXT NOT NULL,
      description TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''';

  // Static method untuk membuat index
  static List<String> get createIndexQueries => [
    'CREATE INDEX idx_transactions_date ON transactions(date)',
    'CREATE INDEX idx_transactions_type ON transactions(type)',
    'CREATE INDEX idx_transactions_category ON transactions(category)',
  ];

  @override
  String toString() {
    return 'Transaction(id: $id, title: $title, amount: $amount, date: $date, type: $type, category: $category, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
        other.id == id &&
        other.title == title &&
        other.amount == amount &&
        other.date == date &&
        other.type == type &&
        other.category == category &&
        other.description == description;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        amount.hashCode ^
        date.hashCode ^
        type.hashCode ^
        category.hashCode ^
        description.hashCode;
  }
}

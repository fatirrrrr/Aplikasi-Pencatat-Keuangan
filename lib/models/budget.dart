// models/budget.dart
class Budget {
  final int? id; // Changed to int for SQLite
  final String categoryName;
  final double amount;
  final DateTime startDate;
  final DateTime endDate;
  final double spent;
  final DateTime createdAt;
  final DateTime updatedAt;

  Budget({
    this.id,
    required this.categoryName,
    required this.amount,
    required this.startDate,
    required this.endDate,
    this.spent = 0.0,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  double get remaining => amount - spent;
  double get percentage => amount > 0 ? spent / amount : 0;
  bool get isExceeded => spent > amount;

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as int?,
      categoryName: map['category_name'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date'] as int),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['end_date'] as int),
      spent: (map['spent'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_name': categoryName,
      'amount': amount,
      'start_date': startDate.millisecondsSinceEpoch,
      'end_date': endDate.millisecondsSinceEpoch,
      'spent': spent,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  Map<String, dynamic> toMapForInsert() {
    return {
      'category_name': categoryName,
      'amount': amount,
      'start_date': startDate.millisecondsSinceEpoch,
      'end_date': endDate.millisecondsSinceEpoch,
      'spent': spent,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  Budget copyWith({
    int? id,
    String? categoryName,
    double? amount,
    DateTime? startDate,
    DateTime? endDate,
    double? spent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      amount: amount ?? this.amount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      spent: spent ?? this.spent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  static String get createTableQuery => '''
    CREATE TABLE budgets (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      category_name TEXT NOT NULL,
      amount REAL NOT NULL,
      start_date INTEGER NOT NULL,
      end_date INTEGER NOT NULL,
      spent REAL NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''';

  static List<String> get createIndexQueries => [
    'CREATE INDEX idx_budgets_category ON budgets(category_name)',
    'CREATE INDEX idx_budgets_dates ON budgets(start_date, end_date)',
  ];

  @override
  String toString() {
    return 'Budget(id: $id, categoryName: $categoryName, amount: $amount, startDate: $startDate, endDate: $endDate, spent: $spent)';
  }
}

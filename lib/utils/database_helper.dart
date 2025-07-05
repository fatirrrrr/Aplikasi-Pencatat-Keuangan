import 'package:expense_tracker/models/budget.dart';
import 'package:expense_tracker/models/category.dart';
import 'package:expense_tracker/models/transaction_type.dart';
import 'package:expense_tracker/models/transactions.dart' as TransactionsModel;
import 'package:expense_tracker/utils/default_categories.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'finance_tracker.db');
    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    // Create tables
    await db.execute(TransactionsModel.Transaction.createTableQuery);
    await db.execute(Category.createTableQuery);
    await db.execute(Budget.createTableQuery);

    // Create indexes
    for (String query in TransactionsModel.Transaction.createIndexQueries) {
      await db.execute(query);
    }
    for (String query in Budget.createIndexQueries) {
      await db.execute(query);
    }

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    for (Category category in DefaultCategories.allCategories) {
      await db.insert('categories', category.toMapForInsert());
    }
  }

  // Transaction CRUD operations
  Future<int> insertTransaction(TransactionsModel.Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMapForInsert());
  }

  Future<List<TransactionsModel.Transaction>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => TransactionsModel.Transaction.fromMap(maps[i]));
  }

  Future<List<TransactionsModel.Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => TransactionsModel.Transaction.fromMap(maps[i]));
  }

  Future<int> updateTransaction(TransactionsModel.Transaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // Category CRUD operations
  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMapForInsert());
  }

  Future<List<Category>> getAllCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<List<Category>> getCategoriesByType(TransactionType type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type.name],
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  // Budget CRUD operations
  Future<int> insertBudget(Budget budget) async {
    final db = await database;
    return await db.insert('budgets', budget.toMapForInsert());
  }

  Future<List<Budget>> getAllBudgets() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('budgets');
    return List.generate(maps.length, (i) => Budget.fromMap(maps[i]));
  }

  Future<int> updateBudget(Budget budget) async {
    final db = await database;
    return await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<int> deleteBudget(int id) async {
    final db = await database;
    return await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

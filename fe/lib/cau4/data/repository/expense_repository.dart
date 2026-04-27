import '../models/expense.dart';
import '../services/database_helper.dart';

class ExpenseRepository {
  final Cau4DatabaseHelper _dbHelper = Cau4DatabaseHelper();

  Future<List<Expense>> getAllExpenses() async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT expenses.*, categories.name as categoryName 
      FROM expenses 
      LEFT JOIN categories ON expenses.categoryId = categories.id 
      ORDER BY expenses.id DESC
    ''');
    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  Future<int> insertExpense(Expense expense) async {
    final db = await _dbHelper.database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await _dbHelper.database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalExpenses() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT SUM(amount) as total FROM expenses');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<Map<String, double>> getTotalsByCategory() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT categories.name, SUM(expenses.amount) as total 
      FROM expenses 
      LEFT JOIN categories ON expenses.categoryId = categories.id 
      GROUP BY categories.id
      HAVING categories.name IS NOT NULL
    ''');

    final totals = <String, double>{};
    for (final row in result) {
      final name = row['name'] as String?;
      final total = (row['total'] as num?)?.toDouble() ?? 0.0;
      if (name != null) {
        totals[name] = total;
      }
    }
    return totals;
  }
}

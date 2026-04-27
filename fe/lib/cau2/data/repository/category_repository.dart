import '../models/category.dart';
import '../services/database_helper.dart';

class CategoryRepository {
  final Cau2DatabaseHelper _dbHelper = Cau2DatabaseHelper();

  Future<List<Category>> getAllCategories() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('categories', orderBy: 'name ASC');
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  Future<int> insertCategory(Category category) async {
    final db = await _dbHelper.database;
    return await db.insert('categories', category.toMap());
  }

  Future<int> updateCategory(Category category) async {
    final db = await _dbHelper.database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

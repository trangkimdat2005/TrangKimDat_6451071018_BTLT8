import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Cau4DatabaseHelper {
  static final Cau4DatabaseHelper _instance = Cau4DatabaseHelper._internal();
  static Database? _database;

  factory Cau4DatabaseHelper() => _instance;

  Cau4DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expenses.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        note TEXT NOT NULL,
        categoryId INTEGER,
        FOREIGN KEY (categoryId) REFERENCES categories(id) ON DELETE SET NULL
      )
    ''');

    // Insert default categories
    final defaultCategories = [
      'Ăn uống',
      'Di chuyển',
      'Mua sắm',
      'Giải trí',
      'Hóa đơn',
      'Sức khỏe',
      'Khác',
    ];

    for (final name in defaultCategories) {
      await db.insert('categories', {'name': name});
    }
  }
}

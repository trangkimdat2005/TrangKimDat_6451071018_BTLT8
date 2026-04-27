import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Cau2DatabaseHelper {
  static final Cau2DatabaseHelper _instance = Cau2DatabaseHelper._internal();
  static Database? _database;

  factory Cau2DatabaseHelper() => _instance;

  Cau2DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cau2_notes.db');

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
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        categoryId INTEGER,
        FOREIGN KEY (categoryId) REFERENCES categories(id) ON DELETE SET NULL
      )
    ''');
  }
}

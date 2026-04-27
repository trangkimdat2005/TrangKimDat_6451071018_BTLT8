import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Cau3DatabaseHelper {
  static final Cau3DatabaseHelper _instance = Cau3DatabaseHelper._internal();
  static Database? _database;

  factory Cau3DatabaseHelper() => _instance;

  Cau3DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tasks.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        isDone INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }
}

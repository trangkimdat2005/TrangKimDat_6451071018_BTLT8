import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Cau6DatabaseHelper {
  static final Cau6DatabaseHelper _instance = Cau6DatabaseHelper._internal();
  static Database? _database;

  factory Cau6DatabaseHelper() => _instance;

  Cau6DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'gallery.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        path TEXT NOT NULL,
        title TEXT,
        createdAt TEXT
      )
    ''');
  }
}

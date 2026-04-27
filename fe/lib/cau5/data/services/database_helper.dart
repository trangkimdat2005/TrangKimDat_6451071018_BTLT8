import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Cau5DatabaseHelper {
  static final Cau5DatabaseHelper _instance = Cau5DatabaseHelper._internal();
  static Database? _database;

  factory Cau5DatabaseHelper() => _instance;

  Cau5DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'dictionary.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE dictionary (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL,
        meaning TEXT NOT NULL
      )
    ''');

    await db.execute('CREATE INDEX idx_word ON dictionary(word)');
  }
}

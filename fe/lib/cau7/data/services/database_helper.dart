import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Cau7DatabaseHelper {
  static final Cau7DatabaseHelper _instance = Cau7DatabaseHelper._internal();
  static Database? _database;

  factory Cau7DatabaseHelper() => _instance;

  Cau7DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'student_course.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE courses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE enrollments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER NOT NULL,
        courseId INTEGER NOT NULL,
        FOREIGN KEY (studentId) REFERENCES students(id) ON DELETE CASCADE,
        FOREIGN KEY (courseId) REFERENCES courses(id) ON DELETE CASCADE,
        UNIQUE(studentId, courseId)
      )
    ''');

    await db.execute('CREATE INDEX idx_studentId ON enrollments(studentId)');
    await db.execute('CREATE INDEX idx_courseId ON enrollments(courseId)');
  }
}

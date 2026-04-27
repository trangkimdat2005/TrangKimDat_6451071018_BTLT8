import '../models/student.dart';
import '../services/database_helper.dart';

class StudentRepository {
  final Cau7DatabaseHelper _dbHelper = Cau7DatabaseHelper();

  Future<List<Student>> getAllStudents() async {
    final db = await _dbHelper.database;
    final maps = await db.query('students', orderBy: 'name ASC');
    return maps.map((map) => Student.fromMap(map)).toList();
  }

  Future<int> insertStudent(Student student) async {
    final db = await _dbHelper.database;
    return await db.insert('students', student.toMap());
  }

  Future<int> updateStudent(Student student) async {
    final db = await _dbHelper.database;
    return await db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteStudent(int id) async {
    final db = await _dbHelper.database;
    await db.delete('enrollments', where: 'studentId = ?', whereArgs: [id]);
    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  Future<Student?> getStudentById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('students', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Student.fromMap(maps.first);
  }
}

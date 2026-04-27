import '../models/course.dart';
import '../services/database_helper.dart';

class EnrollmentRepository {
  final Cau7DatabaseHelper _dbHelper = Cau7DatabaseHelper();

  Future<List<Course>> getCoursesByStudent(int studentId) async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT courses.* FROM courses
      INNER JOIN enrollments ON courses.id = enrollments.courseId
      WHERE enrollments.studentId = ?
      ORDER BY courses.name ASC
    ''', [studentId]);
    return maps.map((map) => Course.fromMap(map)).toList();
  }

  Future<List<int>> getEnrolledCourseIds(int studentId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'enrollments',
      columns: ['courseId'],
      where: 'studentId = ?',
      whereArgs: [studentId],
    );
    return maps.map((map) => map['courseId'] as int).toList();
  }

  Future<void> enrollStudent(int studentId, int courseId) async {
    final db = await _dbHelper.database;
    await db.insert('enrollments', {
      'studentId': studentId,
      'courseId': courseId,
    });
  }

  Future<void> unenrollStudent(int studentId, int courseId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'enrollments',
      where: 'studentId = ? AND courseId = ?',
      whereArgs: [studentId, courseId],
    );
  }

  Future<void> toggleEnrollment(int studentId, int courseId) async {
    final db = await _dbHelper.database;
    final existing = await db.query(
      'enrollments',
      where: 'studentId = ? AND courseId = ?',
      whereArgs: [studentId, courseId],
    );

    if (existing.isEmpty) {
      await db.insert('enrollments', {
        'studentId': studentId,
        'courseId': courseId,
      });
    } else {
      await db.delete(
        'enrollments',
        where: 'studentId = ? AND courseId = ?',
        whereArgs: [studentId, courseId],
      );
    }
  }

  Future<List<Map<String, dynamic>>> getEnrollmentSummary() async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT students.id as studentId, students.name as studentName,
             COUNT(enrollments.id) as courseCount
      FROM students
      LEFT JOIN enrollments ON students.id = enrollments.studentId
      GROUP BY students.id
      ORDER BY students.name ASC
    ''');
  }

  Future<int> getTotalStudents() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM students');
    return result.first['count'] as int;
  }

  Future<int> getTotalCourses() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM courses');
    return result.first['count'] as int;
  }
}

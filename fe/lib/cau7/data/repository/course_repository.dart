import '../models/course.dart';
import '../services/database_helper.dart';

class CourseRepository {
  final Cau7DatabaseHelper _dbHelper = Cau7DatabaseHelper();

  Future<List<Course>> getAllCourses() async {
    final db = await _dbHelper.database;
    final maps = await db.query('courses', orderBy: 'name ASC');
    return maps.map((map) => Course.fromMap(map)).toList();
  }

  Future<int> insertCourse(Course course) async {
    final db = await _dbHelper.database;
    return await db.insert('courses', course.toMap());
  }

  Future<int> updateCourse(Course course) async {
    final db = await _dbHelper.database;
    return await db.update(
      'courses',
      course.toMap(),
      where: 'id = ?',
      whereArgs: [course.id],
    );
  }

  Future<int> deleteCourse(int id) async {
    final db = await _dbHelper.database;
    await db.delete('enrollments', where: 'courseId = ?', whereArgs: [id]);
    return await db.delete('courses', where: 'id = ?', whereArgs: [id]);
  }

  Future<Course?> getCourseById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('courses', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Course.fromMap(maps.first);
  }
}

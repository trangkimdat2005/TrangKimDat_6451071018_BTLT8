import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/task.dart';
import '../services/database_helper.dart';

class TaskRepository {
  final Cau3DatabaseHelper _dbHelper = Cau3DatabaseHelper();

  Future<List<Task>> getAllTasks() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('tasks', orderBy: 'id DESC');
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<int> insertTask(Task task) async {
    final db = await _dbHelper.database;
    return await db.insert('tasks', task.toMap());
  }

  Future<int> updateTask(Task task) async {
    final db = await _dbHelper.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllTasks() async {
    final db = await _dbHelper.database;
    return await db.delete('tasks');
  }

  // Export tasks to JSON file
  Future<String> exportToJson() async {
    final tasks = await getAllTasks();
    final jsonList = tasks.map((task) => task.toJson()).toList();
    final jsonString = const JsonEncoder.withIndent('  ').convert({
      'exportedAt': DateTime.now().toIso8601String(),
      'tasks': jsonList,
    });

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/tasks_backup_$timestamp.json');
    await file.writeAsString(jsonString);

    return file.path;
  }

  // Import tasks from JSON file
  Future<int> importFromJson(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File not found');
    }

    final jsonString = await file.readAsString();
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    final tasksList = jsonData['tasks'] as List<dynamic>;

    // Clear existing tasks and import new ones
    await deleteAllTasks();

    int count = 0;
    for (final taskJson in tasksList) {
      final task = Task.fromJson(taskJson as Map<String, dynamic>);
      // Insert without id to let database auto-generate
      await insertTask(Task(title: task.title, isDone: task.isDone));
      count++;
    }

    return count;
  }

  // Get list of backup files
  Future<List<FileSystemEntity>> getBackupFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory
        .listSync()
        .where((file) => file.path.contains('tasks_backup_') && file.path.endsWith('.json'))
        .toList();
    files.sort((a, b) => b.path.compareTo(a.path)); // Newest first
    return files;
  }
}

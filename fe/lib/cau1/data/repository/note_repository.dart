import '../models/note.dart';
import '../services/database_helper.dart';

class NoteRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Note>> getAllNotes() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('notes', orderBy: 'id DESC');
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  Future<int> insertNote(Note note) async {
    final db = await _dbHelper.database;
    return await db.insert('notes', note.toMap());
  }

  Future<int> updateNote(Note note) async {
    final db = await _dbHelper.database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

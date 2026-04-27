import '../models/note.dart';
import '../services/database_helper.dart';

class NoteRepository {
  final Cau2DatabaseHelper _dbHelper = Cau2DatabaseHelper();

  Future<List<Note>> getAllNotes() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT notes.*, categories.name as categoryName 
      FROM notes 
      LEFT JOIN categories ON notes.categoryId = categories.id 
      ORDER BY notes.id DESC
    ''');
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  Future<List<Note>> getNotesByCategory(int? categoryId) async {
    final db = await _dbHelper.database;
    List<Map<String, dynamic>> maps;

    if (categoryId == null) {
      maps = await db.rawQuery('''
        SELECT notes.*, categories.name as categoryName 
        FROM notes 
        LEFT JOIN categories ON notes.categoryId = categories.id 
        ORDER BY notes.id DESC
      ''');
    } else {
      maps = await db.rawQuery('''
        SELECT notes.*, categories.name as categoryName 
        FROM notes 
        LEFT JOIN categories ON notes.categoryId = categories.id 
        WHERE notes.categoryId = ?
        ORDER BY notes.id DESC
      ''', [categoryId]);
    }
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

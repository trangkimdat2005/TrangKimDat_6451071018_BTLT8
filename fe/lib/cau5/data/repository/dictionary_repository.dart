import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/dictionary_word.dart';
import '../services/database_helper.dart';

class DictionaryRepository {
  final Cau5DatabaseHelper _dbHelper = Cau5DatabaseHelper();

  Future<void> initializeDatabase() async {
    final db = await _dbHelper.database;
    
    final count = await db.rawQuery('SELECT COUNT(*) as count FROM dictionary');
    final total = count.first['count'] as int;
    
    if (total == 0) {
      await _loadJsonToDatabase();
    }
  }

  Future<void> _loadJsonToDatabase() async {
    final db = await _dbHelper.database;
    
    final String jsonString = await rootBundle.loadString('assets/json/dictionary.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final List<dynamic> words = jsonData['dictionary'];

    final batch = db.batch();
    for (final word in words) {
      batch.insert('dictionary', {
        'word': word['word'],
        'meaning': word['meaning'],
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<DictionaryWord>> searchWords(String query) async {
    final db = await _dbHelper.database;
    
    if (query.isEmpty) {
      final maps = await db.query(
        'dictionary',
        orderBy: 'word ASC',
        limit: 50,
      );
      return maps.map((map) => DictionaryWord.fromMap(map)).toList();
    }

    final maps = await db.query(
      'dictionary',
      where: 'word LIKE ? OR meaning LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'word ASC',
    );
    return maps.map((map) => DictionaryWord.fromMap(map)).toList();
  }

  Future<DictionaryWord?> getWordById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'dictionary',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return DictionaryWord.fromMap(maps.first);
  }

  Future<int> getTotalWords() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM dictionary');
    return result.first['count'] as int;
  }
}

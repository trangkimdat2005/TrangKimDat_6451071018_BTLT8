import 'package:flutter/material.dart';
import '../views/note_screen.dart';

class Cau1Routes {
  static const String noteList = '/cau1/notes';
  static const String noteDetail = '/cau1/note-detail';

  static Map<String, WidgetBuilder> get routes => {
    noteList: (context) => const NoteListScreen(),
    noteDetail: (context) => const NoteDetailScreen(),
  };
}

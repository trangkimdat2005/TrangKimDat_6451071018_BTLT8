class Note {
  final int? id;
  final String title;
  final String content;
  final int? categoryId;
  final String? categoryName;

  Note({
    this.id,
    required this.title,
    required this.content,
    this.categoryId,
    this.categoryName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'categoryId': categoryId,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      categoryId: map['categoryId'] as int?,
      categoryName: map['categoryName'] as String?,
    );
  }

  Note copyWith({
    int? id,
    String? title,
    String? content,
    int? categoryId,
    String? categoryName,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
    );
  }
}

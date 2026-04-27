class Task {
  final int? id;
  final String title;
  final bool isDone;

  Task({this.id, required this.title, this.isDone = false});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      isDone: (map['isDone'] as int) == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int?,
      title: json['title'] as String,
      isDone: json['isDone'] as bool? ?? false,
    );
  }

  Task copyWith({int? id, String? title, bool? isDone}) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }
}

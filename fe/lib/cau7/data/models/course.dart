class Course {
  final int? id;
  final String name;

  Course({this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] as int?,
      name: map['name'] as String,
    );
  }

  Course copyWith({int? id, String? name}) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}

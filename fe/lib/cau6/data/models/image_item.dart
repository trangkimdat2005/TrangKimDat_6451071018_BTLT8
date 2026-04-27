class ImageItem {
  final int? id;
  final String path;
  final String? title;
  final DateTime? createdAt;

  ImageItem({
    this.id,
    required this.path,
    this.title,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
      'title': title,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory ImageItem.fromMap(Map<String, dynamic> map) {
    return ImageItem(
      id: map['id'] as int?,
      path: map['path'] as String,
      title: map['title'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
    );
  }

  ImageItem copyWith({
    int? id,
    String? path,
    String? title,
    DateTime? createdAt,
  }) {
    return ImageItem(
      id: id ?? this.id,
      path: path ?? this.path,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

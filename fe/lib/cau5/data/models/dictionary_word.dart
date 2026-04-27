class DictionaryWord {
  final int? id;
  final String word;
  final String meaning;

  DictionaryWord({
    this.id,
    required this.word,
    required this.meaning,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'meaning': meaning,
    };
  }

  factory DictionaryWord.fromMap(Map<String, dynamic> map) {
    return DictionaryWord(
      id: map['id'] as int?,
      word: map['word'] as String,
      meaning: map['meaning'] as String,
    );
  }

  factory DictionaryWord.fromJson(Map<String, dynamic> json) {
    return DictionaryWord(
      word: json['word'] as String,
      meaning: json['meaning'] as String,
    );
  }
}

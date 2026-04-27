class Expense {
  final int? id;
  final double amount;
  final String note;
  final int? categoryId;
  final String? categoryName;

  Expense({
    this.id,
    required this.amount,
    required this.note,
    this.categoryId,
    this.categoryName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'note': note,
      'categoryId': categoryId,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      note: map['note'] as String,
      categoryId: map['categoryId'] as int?,
      categoryName: map['categoryName'] as String?,
    );
  }

  Expense copyWith({
    int? id,
    double? amount,
    String? note,
    int? categoryId,
    String? categoryName,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
    );
  }
}

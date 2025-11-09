class TransactionModel {
  final String? id;
  final String uid;
  final String type; // 'income' or 'expense'
  final String category;
  final double amount;
  final String? description;
  final DateTime date;
  final DateTime createdAt;

  TransactionModel({
    this.id,
    required this.uid,
    required this.type,
    required this.category,
    required this.amount,
    this.description,
    required this.date,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Create from database map
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String?,
      uid: map['uid'] as String,
      type: map['type'] as String,
      category: map['category'] as String,
      amount: map['amount'] as double,
      description: map['description'] as String?,
      date: DateTime.parse(map['date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'type': type,
      'category': category,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create copy with updated fields
  TransactionModel copyWith({
    String? id,
    String? uid,
    String? type,
    String? category,
    double? amount,
    String? description,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, uid: $uid, type: $type, category: $category, amount: $amount, description: $description, date: $date, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransactionModel &&
        other.id == id &&
        other.uid == uid &&
        other.type == type &&
        other.category == category &&
        other.amount == amount &&
        other.description == description &&
        other.date == date &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        uid.hashCode ^
        type.hashCode ^
        category.hashCode ^
        amount.hashCode ^
        description.hashCode ^
        date.hashCode ^
        createdAt.hashCode;
  }
}

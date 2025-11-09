class GoalModel {
  final String? id;
  final String uid;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final DateTime createdAt;

  GoalModel({
    this.id,
    required this.uid,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.deadline,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Create from database map
  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'] as String?,
      uid: map['uid'] as String,
      name: map['name'] as String,
      targetAmount: map['target_amount'] as double,
      currentAmount: map['current_amount'] as double? ?? 0.0,
      deadline: map['deadline'] != null
          ? DateTime.parse(map['deadline'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'deadline': deadline?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create copy with updated fields
  GoalModel copyWith({
    String? id,
    String? uid,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    DateTime? createdAt,
  }) {
    return GoalModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Calculate progress percentage
  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  // Check if goal is completed
  bool get isCompleted => currentAmount >= targetAmount;

  // Check if goal is overdue
  bool get isOverdue {
    if (deadline == null) return false;
    return DateTime.now().isAfter(deadline!) && !isCompleted;
  }

  // Get remaining amount to reach goal
  double get remainingAmount =>
      (targetAmount - currentAmount).clamp(0.0, double.infinity);

  @override
  String toString() {
    return 'GoalModel(id: $id, uid: $uid, name: $name, targetAmount: $targetAmount, currentAmount: $currentAmount, deadline: $deadline, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GoalModel &&
        other.id == id &&
        other.uid == uid &&
        other.name == name &&
        other.targetAmount == targetAmount &&
        other.currentAmount == currentAmount &&
        other.deadline == deadline &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        uid.hashCode ^
        name.hashCode ^
        targetAmount.hashCode ^
        currentAmount.hashCode ^
        deadline.hashCode ^
        createdAt.hashCode;
  }
}

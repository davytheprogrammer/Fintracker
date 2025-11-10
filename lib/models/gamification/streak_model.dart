import 'package:cloud_firestore/cloud_firestore.dart';

enum StreakType { daily, weekly, monthly, custom }

class StreakModel {
  final String id;
  final String name;
  final StreakType type;
  final int currentCount;
  final int longestCount;
  final DateTime? lastActivityDate;
  final List<DateTime> resetDates;
  final bool isActive;

  const StreakModel({
    required this.id,
    required this.name,
    required this.type,
    this.currentCount = 0,
    this.longestCount = 0,
    this.lastActivityDate,
    this.resetDates = const [],
    this.isActive = true,
  });

  factory StreakModel.fromMap(Map<String, dynamic> map) {
    return StreakModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: StreakType.values[map['type'] ?? 0],
      currentCount: map['currentCount'] ?? 0,
      longestCount: map['longestCount'] ?? 0,
      lastActivityDate: map['lastActivityDate'] != null
          ? (map['lastActivityDate'] as Timestamp).toDate()
          : null,
      resetDates: (map['resetDates'] as List<dynamic>?)
              ?.map((date) => (date as Timestamp).toDate())
              .toList() ??
          [],
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'currentCount': currentCount,
      'longestCount': longestCount,
      'lastActivityDate': lastActivityDate != null
          ? Timestamp.fromDate(lastActivityDate!)
          : null,
      'resetDates': resetDates.map((date) => Timestamp.fromDate(date)).toList(),
      'isActive': isActive,
    };
  }

  StreakModel copyWith({
    String? id,
    String? name,
    StreakType? type,
    int? currentCount,
    int? longestCount,
    DateTime? lastActivityDate,
    List<DateTime>? resetDates,
    bool? isActive,
  }) {
    return StreakModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      currentCount: currentCount ?? this.currentCount,
      longestCount: longestCount ?? this.longestCount,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      resetDates: resetDates ?? this.resetDates,
      isActive: isActive ?? this.isActive,
    );
  }

  bool shouldReset(DateTime currentDate) {
    if (lastActivityDate == null) return false;

    final daysSinceLastActivity =
        currentDate.difference(lastActivityDate!).inDays;
    final threshold = _getResetThreshold();

    return daysSinceLastActivity > threshold;
  }

  int _getResetThreshold() {
    switch (type) {
      case StreakType.daily:
        return 1;
      case StreakType.weekly:
        return 7;
      case StreakType.monthly:
        return 30;
      case StreakType.custom:
        return 1;
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'badge_model.dart';
import 'streak_model.dart';

class UserGamificationModel {
  final String uid;
  final Map<String, StreakModel> streaks;
  final List<String> unlockedBadges;
  final Map<String, int> badgeProgress;
  final int totalPoints;
  final Map<String, dynamic> stats;
  final DateTime lastUpdated;

  const UserGamificationModel({
    required this.uid,
    required this.streaks,
    required this.unlockedBadges,
    required this.badgeProgress,
    required this.totalPoints,
    required this.stats,
    required this.lastUpdated,
  });

  factory UserGamificationModel.fromMap(Map<String, dynamic> map) {
    final streaksMap = <String, StreakModel>{};
    if (map['streaks'] != null) {
      (map['streaks'] as Map<String, dynamic>).forEach((key, value) {
        streaksMap[key] = StreakModel.fromMap(value);
      });
    }

    final badgeProgressMap = <String, int>{};
    if (map['badgeProgress'] != null) {
      (map['badgeProgress'] as Map<String, dynamic>).forEach((key, value) {
        badgeProgressMap[key] = value as int;
      });
    }

    return UserGamificationModel(
      uid: map['uid'] ?? '',
      streaks: streaksMap,
      unlockedBadges: List<String>.from(map['unlockedBadges'] ?? []),
      badgeProgress: badgeProgressMap,
      totalPoints: map['totalPoints'] ?? 0,
      stats: Map<String, dynamic>.from(map['stats'] ?? {}),
      lastUpdated: map['lastUpdated'] != null
          ? (map['lastUpdated'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    final streaksMap = <String, dynamic>{};
    streaks.forEach((key, value) {
      streaksMap[key] = value.toMap();
    });

    return {
      'uid': uid,
      'streaks': streaksMap,
      'unlockedBadges': unlockedBadges,
      'badgeProgress': badgeProgress,
      'totalPoints': totalPoints,
      'stats': stats,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  UserGamificationModel copyWith({
    String? uid,
    Map<String, StreakModel>? streaks,
    List<String>? unlockedBadges,
    Map<String, int>? badgeProgress,
    int? totalPoints,
    Map<String, dynamic>? stats,
    DateTime? lastUpdated,
  }) {
    return UserGamificationModel(
      uid: uid ?? this.uid,
      streaks: streaks ?? this.streaks,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      badgeProgress: badgeProgress ?? this.badgeProgress,
      totalPoints: totalPoints ?? this.totalPoints,
      stats: stats ?? this.stats,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  bool hasBadge(String badgeId) {
    return unlockedBadges.contains(badgeId);
  }

  int getStreakCount(String streakId) {
    return streaks[streakId]?.currentCount ?? 0;
  }

  int getBadgeProgress(String badgeId) {
    return badgeProgress[badgeId] ?? 0;
  }

  bool isStreakActive(String streakId) {
    return streaks[streakId]?.isActive ?? false;
  }
}

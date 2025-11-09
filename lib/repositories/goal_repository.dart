import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/goal_model.dart';

class GoalRepository {
  static GoalRepository? _instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  GoalRepository._privateConstructor();
  factory GoalRepository() {
    _instance ??= GoalRepository._privateConstructor();
    return _instance!;
  }

  static const String _cacheKeyPrefix = 'goals_cache_';
  static const String _cacheTimestampPrefix = 'goals_cache_timestamp_';
  static const Duration _cacheExpiry = Duration(minutes: 30);

  String _getCacheKey(String uid) => '$_cacheKeyPrefix$uid';
  String _getTimestampKey(String uid) => '$_cacheTimestampPrefix$uid';

  Future<void> _cacheGoals(String uid, List<GoalModel> goals) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsJson = jsonEncode(goals.map((g) => g.toMap()).toList());
      await prefs.setString(_getCacheKey(uid), goalsJson);
      await prefs.setInt(
          _getTimestampKey(uid), DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Failed to cache goals: $e');
    }
  }

  Future<List<GoalModel>?> _getCachedGoals(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_getCacheKey(uid));
      final timestamp = prefs.getInt(_getTimestampKey(uid));

      if (cachedJson != null && timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cacheTime) < _cacheExpiry) {
          final List<dynamic> data = jsonDecode(cachedJson);
          return data.map((g) => GoalModel.fromMap(g)).toList();
        }
      }
    } catch (e) {
      debugPrint('Failed to retrieve cached goals: $e');
    }
    return null;
  }

  Future<void> _clearCache(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_getCacheKey(uid));
      await prefs.remove(_getTimestampKey(uid));
    } catch (e) {
      debugPrint('Failed to clear cache: $e');
    }
  }

  Future<String> createGoal(GoalModel goal, String uid) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(uid)
          .collection('goals')
          .add(goal.toMap());
      await _clearCache(uid);
      debugPrint('Goal created in Firestore');
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create goal: $e');
    }
  }

  Future<List<GoalModel>> getUserGoals(String uid) async {
    try {
      final cached = await _getCachedGoals(uid);
      if (cached != null) return cached;

      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('goals')
          .orderBy('createdAt', descending: true)
          .get();

      final goals = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return GoalModel.fromMap(data);
      }).toList();

      await _cacheGoals(uid, goals);
      return goals;
    } catch (e) {
      throw Exception('Failed to get user goals: $e');
    }
  }

  Future<GoalModel?> getGoalById(String goalId, String uid) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('goals')
          .doc(goalId)
          .get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      data['id'] = doc.id;
      return GoalModel.fromMap(data);
    } catch (e) {
      throw Exception('Failed to get goal: $e');
    }
  }

  Future<void> updateGoal(String goalId, GoalModel goal, String uid) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('goals')
          .doc(goalId)
          .update(goal.toMap());
      await _clearCache(uid);
    } catch (e) {
      throw Exception('Failed to update goal: $e');
    }
  }

  Future<void> updateGoalProgress(
      String goalId, String uid, double newAmount) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('goals')
          .doc(goalId)
          .update({'currentAmount': newAmount});
      await _clearCache(uid);
    } catch (e) {
      throw Exception('Failed to update goal progress: $e');
    }
  }

  Future<void> deleteGoal(String goalId, String uid) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('goals')
          .doc(goalId)
          .delete();
      await _clearCache(uid);
    } catch (e) {
      throw Exception('Failed to delete goal: $e');
    }
  }

  Stream<List<GoalModel>> streamUserGoals(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      final goals = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return GoalModel.fromMap(data);
      }).toList();
      _cacheGoals(uid, goals);
      return goals;
    });
  }

  Future<Map<String, dynamic>> getGoalStatistics(String uid) async {
    try {
      final goals = await getUserGoals(uid);

      int totalGoals = goals.length;
      int completedGoals = goals.where((goal) => goal.isCompleted).length;
      int overdueGoals = goals.where((goal) => goal.isOverdue).length;
      int activeGoals = totalGoals - completedGoals - overdueGoals;

      double totalTargetAmount =
          goals.fold(0.0, (sum, goal) => sum + goal.targetAmount);
      double totalCurrentAmount =
          goals.fold(0.0, (sum, goal) => sum + goal.currentAmount);
      double overallProgress = totalTargetAmount > 0
          ? (totalCurrentAmount / totalTargetAmount).clamp(0.0, 1.0)
          : 0.0;

      return {
        'totalGoals': totalGoals,
        'completedGoals': completedGoals,
        'overdueGoals': overdueGoals,
        'activeGoals': activeGoals,
        'totalTargetAmount': totalTargetAmount,
        'totalCurrentAmount': totalCurrentAmount,
        'overallProgress': overallProgress,
        'completionRate': totalGoals > 0 ? (completedGoals / totalGoals) : 0.0,
      };
    } catch (e) {
      throw Exception('Failed to get goal statistics: $e');
    }
  }

  Future<List<GoalModel>> getGoalsByStatus(String uid, String status) async {
    try {
      final goals = await getUserGoals(uid);
      switch (status.toLowerCase()) {
        case 'active':
          return goals
              .where((goal) => !goal.isCompleted && !goal.isOverdue)
              .toList();
        case 'completed':
          return goals.where((goal) => goal.isCompleted).toList();
        case 'overdue':
          return goals.where((goal) => goal.isOverdue).toList();
        default:
          return goals;
      }
    } catch (e) {
      throw Exception('Failed to get goals by status: $e');
    }
  }

  Future<List<GoalModel>> getGoalsNearingDeadline(String uid,
      {int daysAhead = 30}) async {
    try {
      final goals = await getUserGoals(uid);
      final now = DateTime.now();
      final futureDate = now.add(Duration(days: daysAhead));

      return goals.where((goal) {
        if (goal.deadline == null) return false;
        return goal.deadline!.isAfter(now) &&
            goal.deadline!.isBefore(futureDate) &&
            !goal.isCompleted;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get goals nearing deadline: $e');
    }
  }

  Future<void> addToGoalProgress(
      String goalId, String uid, double amount) async {
    try {
      final goal = await getGoalById(goalId, uid);
      if (goal == null) throw Exception('Goal not found');

      final newAmount = goal.currentAmount + amount;
      await updateGoalProgress(goalId, uid, newAmount);
    } catch (e) {
      throw Exception('Failed to add to goal progress: $e');
    }
  }

  Future<void> syncGoals(String uid) async {
    try {
      // Clear cache to force fresh data
      await _clearCache(uid);
      debugPrint('Goals synced for user: $uid');
    } catch (e) {
      throw Exception('Failed to sync goals: $e');
    }
  }

  Future<void> clearAllCaches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_cacheKeyPrefix) ||
            key.startsWith(_cacheTimestampPrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      debugPrint('Failed to clear all caches: $e');
    }
  }
}

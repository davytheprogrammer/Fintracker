import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/gamification/badge_model.dart';
import '../../models/gamification/streak_model.dart';
import '../../models/gamification/user_gamification_model.dart';
import '../../repositories/transaction_repository.dart';
import '../../repositories/goal_repository.dart';
import '../../services/notification.dart';

class GamificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TransactionRepository _transactionRepository = TransactionRepository();
  final GoalRepository _goalRepository = GoalRepository();
  final NotificationService _notificationService = NotificationService();

  // Badge definitions
  final Map<String, BadgeModel> _badgeDefinitions = {
    'first_transaction': BadgeModel(
      id: 'first_transaction',
      name: 'First Steps',
      description: 'Log your first transaction',
      category: BadgeCategory.achievement,
      tier: 1,
      icon: Icons.celebration,
      rarity: BadgeRarity.common,
      points: 5,
      criteria: {'transactionCount': 1},
    ),
    'budget_master_1': BadgeModel(
      id: 'budget_master_1',
      name: 'Budget Beginner',
      description: 'Complete your first budget cycle successfully',
      category: BadgeCategory.milestone,
      tier: 1,
      icon: Icons.account_balance_wallet,
      rarity: BadgeRarity.common,
      points: 10,
      criteria: {'budgetCyclesCompleted': 1},
    ),
    'daily_logger_7': BadgeModel(
      id: 'daily_logger_7',
      name: 'Daily Logger',
      description: 'Log transactions for 7 consecutive days',
      category: BadgeCategory.consistency,
      tier: 1,
      icon: Icons.calendar_today,
      rarity: BadgeRarity.uncommon,
      points: 15,
      criteria: {'streakCount': 7, 'streakType': 'daily_transaction'},
    ),
    'savings_champion_10': BadgeModel(
      id: 'savings_champion_10',
      name: 'Savings Champion',
      description: 'Reach 10% of your savings goal',
      category: BadgeCategory.milestone,
      tier: 1,
      icon: Icons.savings,
      rarity: BadgeRarity.rare,
      points: 25,
      criteria: {'goalProgress': 10},
    ),
  };

  // Check and award badges based on user actions
  Future<void> checkAndAwardBadges(String uid, String action,
      {Map<String, dynamic>? context}) async {
    try {
      final gamificationData = await _getUserGamificationData(uid);
      if (gamificationData == null) return;

      final unlockedBadges = gamificationData.unlockedBadges;

      for (final badge in _badgeDefinitions.values) {
        if (unlockedBadges.contains(badge.id)) continue;

        if (await _checkBadgeCriteria(uid, badge, action, context)) {
          await _awardBadge(uid, badge);
          await _sendBadgeNotification(badge);
        }
      }
    } catch (e) {
      print('Error checking badges: $e');
    }
  }

  // Update streaks based on user actions
  Future<void> updateStreaks(String uid, String action) async {
    try {
      final gamificationData = await _getUserGamificationData(uid);
      if (gamificationData == null) return;

      final streaks = Map<String, StreakModel>.from(gamificationData.streaks);

      switch (action) {
        case 'transaction_logged':
          await _updateTransactionStreak(uid, streaks);
          break;
        case 'budget_checked':
          await _updateBudgetStreak(uid, streaks);
          break;
        case 'analytics_viewed':
          await _updateAnalyticsStreak(uid, streaks);
          break;
        case 'goal_achieved':
          await _updateGoalStreak(uid, streaks);
          break;
      }

      await _saveGamificationData(
          uid,
          gamificationData.copyWith(
            streaks: streaks,
            lastUpdated: DateTime.now(),
          ));
    } catch (e) {
      print('Error updating streaks: $e');
    }
  }

  Future<bool> _checkBadgeCriteria(String uid, BadgeModel badge, String action,
      Map<String, dynamic>? context) async {
    try {
      switch (badge.id) {
        case 'first_transaction':
          final transactionCount = await _getUserTransactionCount(uid);
          return transactionCount >= 1;

        case 'budget_master_1':
          final budgetCycles = await _getCompletedBudgetCycles(uid);
          return budgetCycles >= 1;

        case 'daily_logger_7':
          final streak = await _getCurrentStreak(uid, 'daily_transaction');
          return streak >= 7;

        case 'savings_champion_10':
          final goalProgress = await _getSavingsGoalProgress(uid);
          return goalProgress >= 10;

        default:
          return false;
      }
    } catch (e) {
      print('Error checking badge criteria: $e');
      return false;
    }
  }

  Future<void> _awardBadge(String uid, BadgeModel badge) async {
    try {
      final gamificationRef =
          _firestore.collection('users').doc(uid).collection('gamification');

      final batch = _firestore.batch();

      // Add to unlocked badges
      batch.set(
        gamificationRef.doc('badges').collection('unlocked').doc(badge.id),
        {
          'badgeId': badge.id,
          'unlockedAt': FieldValue.serverTimestamp(),
          'progress': 100,
          'maxProgress': 100,
          'isActive': true,
        },
        SetOptions(merge: true),
      );

      // Update user stats
      batch.update(gamificationRef.doc('stats'), {
        'totalPoints': FieldValue.increment(badge.points),
        'badgesUnlocked': FieldValue.increment(1),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      print('Error awarding badge: $e');
      throw e;
    }
  }

  Future<void> _sendBadgeNotification(BadgeModel badge) async {
    try {
      await _notificationService.notifyBadgeUnlocked(
          badge.name, badge.description);
    } catch (e) {
      print('Error sending badge notification: $e');
    }
  }

  Future<void> _sendStreakResetNotification(String streakName) async {
    try {
      await _notificationService.notifyStreakBroken(streakName);
    } catch (e) {
      print('Error sending streak reset notification: $e');
    }
  }

  Future<void> _updateTransactionStreak(
      String uid, Map<String, StreakModel> streaks) async {
    final streakId = 'daily_transaction';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    StreakModel streak = streaks[streakId] ??
        StreakModel(
          id: streakId,
          name: 'Daily Transaction',
          type: StreakType.daily,
        );

    final lastActivity = streak.lastActivityDate;
    final lastActivityDay = lastActivity != null
        ? DateTime(lastActivity.year, lastActivity.month, lastActivity.day)
        : null;

    if (lastActivityDay == null) {
      // First activity
      streak = streak.copyWith(
        currentCount: 1,
        longestCount: 1,
        lastActivityDate: now,
      );
    } else if (lastActivityDay == today) {
      // Already logged today, no change
      return;
    } else if (lastActivityDay == today.subtract(const Duration(days: 1))) {
      // Consecutive day
      final newCount = streak.currentCount + 1;
      streak = streak.copyWith(
        currentCount: newCount,
        longestCount:
            newCount > streak.longestCount ? newCount : streak.longestCount,
        lastActivityDate: now,
      );
    } else {
      // Streak broken
      await _notificationService.notifyStreakBroken(streak.name);
      streak = streak.copyWith(
        currentCount: 1,
        lastActivityDate: now,
        resetDates: [...streak.resetDates, now],
      );
    }

    streaks[streakId] = streak;

    // Check for streak milestones
    if (streak.currentCount >= 7 && streak.currentCount % 7 == 0) {
      await _notificationService.notifyStreakMilestone(
          streak.name, streak.currentCount);
    }
  }

  Future<void> _updateBudgetStreak(
      String uid, Map<String, StreakModel> streaks) async {
    // Similar logic for budget streaks
    final streakId = 'monthly_budget';
    // Implementation for budget streak tracking
  }

  Future<void> _updateAnalyticsStreak(
      String uid, Map<String, StreakModel> streaks) async {
    // Similar logic for analytics streaks
    final streakId = 'weekly_analytics';
    // Implementation for analytics streak tracking
  }

  Future<void> _updateGoalStreak(
      String uid, Map<String, StreakModel> streaks) async {
    // Similar logic for goal streaks
    final streakId = 'goal_achievement';
    // Implementation for goal streak tracking
  }

  Future<UserGamificationModel?> _getUserGamificationData(String uid) async {
    try {
      final gamificationRef =
          _firestore.collection('users').doc(uid).collection('gamification');

      final progressDoc = await gamificationRef.doc('progress').get();
      final statsDoc = await gamificationRef.doc('stats').get();

      if (!statsDoc.exists) return null;

      return UserGamificationModel.fromMap({
        'uid': uid,
        ...progressDoc.data() ?? {},
        ...statsDoc.data()!,
      });
    } catch (e) {
      print('Error getting gamification data: $e');
      return null;
    }
  }

  Future<void> _saveGamificationData(
      String uid, UserGamificationModel data) async {
    try {
      final gamificationRef =
          _firestore.collection('users').doc(uid).collection('gamification');

      await gamificationRef
          .doc('progress')
          .set(data.toMap(), SetOptions(merge: true));
    } catch (e) {
      print('Error saving gamification data: $e');
      throw e;
    }
  }

  Future<int> _getUserTransactionCount(String uid) async {
    try {
      final transactions =
          await _transactionRepository.getTransactions(uid: uid);
      return transactions.length;
    } catch (e) {
      print('Error getting transaction count: $e');
      return 0;
    }
  }

  Future<int> _getCompletedBudgetCycles(String uid) async {
    // Implementation to check completed budget cycles
    // This would need to be implemented based on your budget tracking logic
    return 0;
  }

  Future<int> _getCurrentStreak(String uid, String streakId) async {
    final data = await _getUserGamificationData(uid);
    return data?.getStreakCount(streakId) ?? 0;
  }

  Future<double> _getSavingsGoalProgress(String uid) async {
    try {
      final goals = await _goalRepository.getUserGoals(uid);
      if (goals.isEmpty) return 0;

      // Calculate average progress across all goals (assuming all are savings-related for now)
      final totalProgress = goals.fold<double>(
          0, (sum, goal) => sum + goal.progressPercentage * 100);
      return totalProgress / goals.length;
    } catch (e) {
      print('Error getting savings goal progress: $e');
      return 0;
    }
  }

  // Public method to get user gamification data
  Future<UserGamificationModel?> getUserGamificationData(String uid) async {
    return _getUserGamificationData(uid);
  }
}

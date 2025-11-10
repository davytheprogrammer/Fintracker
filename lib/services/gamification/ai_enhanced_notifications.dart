import 'package:flutter/material.dart';
import '../../models/gamification/badge_model.dart';
import '../../models/user_model.dart';
import '../../repositories/transaction_repository.dart';
import '../../repositories/goal_repository.dart';
import '../../services/notification.dart';
import '../../services/ai_service.dart';

class AIEnhancedNotifications {
  final AIService _aiService = AIService();
  final TransactionRepository _transactionRepository = TransactionRepository();
  final GoalRepository _goalRepository = GoalRepository();
  final NotificationService _notificationService = NotificationService();

  Future<String> generatePersonalizedBadgeMessage(
    BadgeModel badge,
    UserModel user,
    Map<String, dynamic> context,
  ) async {
    try {
      final prompt = '''
You are a friendly financial coach. A user just unlocked this achievement:

Badge: ${badge.name}
Description: ${badge.description}
Category: ${badge.category.toString().split('.').last}
Points: ${badge.points}

User Profile:
- Goals: ${user.goals?.join(', ') ?? 'Not specified'}
- Risk Tolerance: ${user.riskTolerance ?? 'Moderate'}
- Income Range: ${user.incomeRange ?? 'Not specified'}
- Occupation: ${user.occupation ?? 'Not specified'}

Recent Context: ${context.isNotEmpty ? context.toString() : 'No additional context'}

Generate a short, encouraging congratulatory message (max 100 characters) that:
1. Celebrates the achievement
2. Relates it to their financial goals
3. Includes one actionable next step
4. Uses emojis appropriately

Example: "🎉 Amazing! Your first transaction logged. Keep building that savings habit! 💰"
''';

      final message = await _aiService.generateNotificationMessage(prompt);

      // Ensure message is not too long
      return message.length > 100 ? message.substring(0, 97) + '...' : message;
    } catch (e) {
      print('Error generating AI badge message: $e');
      return '🎉 Congratulations on unlocking ${badge.name}! Keep up the great work!';
    }
  }

  Future<String> generatePredictiveSpendingAlert(
    UserModel user,
    Map<String, dynamic> spendingData,
  ) async {
    try {
      final prompt = '''
You are a smart financial assistant. Analyze this spending pattern and generate a predictive alert:

User Profile:
- Risk Tolerance: ${user.riskTolerance ?? 'Moderate'}
- Goals: ${user.goals?.join(', ') ?? 'General savings'}

Spending Data: ${spendingData.toString()}

Generate a predictive spending alert (max 120 characters) that:
1. Identifies a potential spending trend
2. Suggests preventive action
3. Ties to their financial goals
4. Uses appropriate emojis

Example: "📈 Spending on dining up 25%. Consider meal prepping to save KES 2,000/month for your vacation goal! 🏖️"
''';

      final message = await _aiService.generateNotificationMessage(prompt);

      return message.length > 120 ? message.substring(0, 117) + '...' : message;
    } catch (e) {
      print('Error generating predictive alert: $e');
      return '📊 Time to review your spending habits! 💡';
    }
  }

  Future<String> generateGoalMotivationMessage(
    UserModel user,
    Map<String, dynamic> goalData,
  ) async {
    try {
      final prompt = '''
You are a motivational financial coach. Create an encouraging message for goal progress:

Goal Progress: ${goalData.toString()}
Risk Tolerance: ${user.riskTolerance ?? 'Moderate'}
Goals: ${user.goals?.join(', ') ?? 'General savings'}

Generate a motivational message (max 100 characters) that:
1. Acknowledges progress made
2. Provides encouragement
3. Suggests next action
4. Uses positive, energetic language

Example: "🚀 Halfway to your dream vacation! Just 3 more months of consistent saving! 💪"
''';

      final message = await _aiService.generateNotificationMessage(prompt);

      return message.length > 100 ? message.substring(0, 97) + '...' : message;
    } catch (e) {
      print('Error generating goal motivation: $e');
      return '🎯 You\'re making great progress! Keep going! 💪';
    }
  }

  Future<String> generateStreakEncouragement(
    String streakType,
    int currentCount,
    UserModel user,
  ) async {
    try {
      final prompt = '''
You are an enthusiastic fitness coach for financial habits. Create streak encouragement:

Streak Type: $streakType
Current Count: $currentCount days
User Goals: ${user.goals?.join(', ') ?? 'Financial wellness'}

Generate an exciting encouragement message (max 90 characters) that:
1. Celebrates the streak milestone
2. Builds momentum
3. Relates to long-term benefits
4. Uses energetic emojis

Example: "🔥 7-day savings streak! You're building wealth super fast! 🚀"
''';

      final message = await _aiService.generateNotificationMessage(prompt);

      return message.length > 90 ? message.substring(0, 87) + '...' : message;
    } catch (e) {
      print('Error generating streak encouragement: $e');
      return '🔥 $currentCount-day streak! You\'re unstoppable!';
    }
  }

  // Enhanced notification methods
  Future<void> sendAIEnhancedBadgeNotification(
    BadgeModel badge,
    UserModel user,
    Map<String, dynamic> context,
  ) async {
    try {
      final aiMessage =
          await generatePersonalizedBadgeMessage(badge, user, context);

      await _notificationService.showAINotification(
        title: '🏆 Achievement Unlocked!',
        body: aiMessage,
        badgeId: badge.id,
      );
    } catch (e) {
      // Fallback to regular notification
      await _notificationService.notifyBadgeUnlocked(
          badge.name, badge.description);
    }
  }

  Future<void> sendPredictiveSpendingNotification(
    UserModel user,
    Map<String, dynamic> spendingData,
  ) async {
    try {
      final aiMessage =
          await generatePredictiveSpendingAlert(user, spendingData);

      await _notificationService.showAINotification(
        title: '📊 Smart Spending Alert',
        body: aiMessage,
        category: 'predictive',
      );
    } catch (e) {
      // Fallback to regular notification
      await _notificationService
          .notifyBudgetWarning('Time to review your spending patterns!');
    }
  }

  Future<void> sendGoalMotivationNotification(
    UserModel user,
    Map<String, dynamic> goalData,
  ) async {
    try {
      final aiMessage = await generateGoalMotivationMessage(user, goalData);

      await _notificationService.showAINotification(
        title: '🎯 Goal Update',
        body: aiMessage,
        category: 'motivation',
      );
    } catch (e) {
      // Fallback to regular notification
      await _notificationService
          .notifyBudgetWarning('Keep working towards your goals!');
    }
  }

  Future<void> sendStreakCelebrationNotification(
    String streakType,
    int currentCount,
    UserModel user,
  ) async {
    try {
      final aiMessage =
          await generateStreakEncouragement(streakType, currentCount, user);

      await _notificationService.showAINotification(
        title: '🔥 Streak Alert!',
        body: aiMessage,
        category: 'streak',
      );
    } catch (e) {
      // Fallback to regular notification
      await _notificationService.notifyStreakMilestone(
          streakType, currentCount);
    }
  }
}

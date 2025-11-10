import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Initialize the service
  Future<void> init() async {
    await AwesomeNotifications().initialize(
      'resource://drawable/res_app_icon',
      [
        NotificationChannel(
          channelKey: 'daily_finance_reminder',
          channelName: 'Finance Reminders',
          channelDescription: 'Daily reminders to update financial data',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: 'budget_warnings',
          channelName: 'Budget Warnings',
          channelDescription: 'Alerts for budget thresholds',
          defaultColor: Colors.red,
          ledColor: Colors.red,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: 'usage_limits',
          channelName: 'Usage Limits',
          channelDescription: 'Daily usage limit notifications',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: 'badge_unlocks',
          channelName: 'Badge Unlocks',
          channelDescription: 'Notifications for unlocked badges',
          defaultColor: const Color(0xFF6C63FF),
          ledColor: const Color(0xFF6C63FF),
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableLights: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: 'streak_milestones',
          channelName: 'Streak Milestones',
          channelDescription: 'Notifications for streak achievements',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.Default,
          channelShowBadge: true,
          playSound: true,
        ),
        NotificationChannel(
          channelKey: 'streak_resets',
          channelName: 'Streak Resets',
          channelDescription: 'Notifications when streaks are broken',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.Low,
          channelShowBadge: true,
          playSound: false,
        ),
        NotificationChannel(
          channelKey: 'ai_enhanced_notifications',
          channelName: 'AI Enhanced Notifications',
          channelDescription: 'Personalized notifications powered by AI',
          defaultColor: const Color(0xFF6C63FF),
          ledColor: const Color(0xFF6C63FF),
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableLights: true,
          enableVibration: true,
        ),
      ],
    );

    // Request permissions
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  // Schedule daily financial reminder (9 AM)
  Future<void> scheduleDailyFinancialReminder() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'daily_finance_reminder',
        title: '💰 Financial Checkup',
        body: 'Update your finances today! Keep your analytics accurate.',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        hour: 9,
        minute: 0,
        second: 0,
        repeats: true,
      ),
    );
  }

  // Notify when budget reaches critical thresholds
  Future<void> notifyBudgetWarning(String message) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 2,
        channelKey: 'budget_warnings',
        title: '⚠️ Budget Alert',
        body: message,
        notificationLayout: NotificationLayout.Default,
        color: Colors.red,
      ),
    );
  }

  // Notify about daily usage limits
  Future<void> notifyDailyLimit(String message) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 3,
        channelKey: 'usage_limits',
        title: '🔔 Usage Alert',
        body: message,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  // Gamification-specific notifications
  Future<void> notifyBadgeUnlocked(String badgeName, String description) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 100,
        channelKey: 'badge_unlocks',
        title: '🏆 Badge Unlocked!',
        body: 'Congratulations! You earned "$badgeName"',
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  Future<void> notifyStreakMilestone(String streakName, int count) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 101,
        channelKey: 'streak_milestones',
        title: '🔥 Streak Alert!',
        body: 'Amazing! $count days on your $streakName streak!',
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  Future<void> notifyStreakBroken(String streakName) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 102,
        channelKey: 'streak_resets',
        title: '💔 Streak Reset',
        body: 'Your $streakName streak has been reset. Keep going!',
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  // AI-enhanced notifications
  Future<void> showAINotification({
    required String title,
    required String body,
    String? badgeId,
    String? category,
  }) async {
    final id =
        badgeId?.hashCode ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'ai_enhanced_notifications',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        payload: {'badgeId': badgeId ?? '', 'category': category ?? ''},
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;
// ignore: depend_on_referenced_packages
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize the service
  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await notificationsPlugin.initialize(settings);
  }

  // Schedule daily financial reminder (9 AM)
  Future<void> scheduleDailyFinancialReminder() async {
    await notificationsPlugin.zonedSchedule(
      1,
      '💰 Financial Checkup',
      'Update your finances today! Keep your analytics accurate.',
      _nextDailyTime(9, 0), // 9:00 AM daily
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_finance_reminder',
          'Finance Reminders',
          channelDescription: 'Daily reminders to update financial data',
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Notify when budget reaches critical thresholds
  Future<void> notifyBudgetWarning(String message) async {
    await notificationsPlugin.show(
      2,
      '⚠️ Budget Alert',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_warnings',
          'Budget Warnings',
          channelDescription: 'Alerts for budget thresholds',
          importance: Importance.max,
          priority: Priority.high,
          colorized: true,
          color: Colors.red,
        ),
      ),
    );
  }

  // Notify about daily usage limits
  Future<void> notifyDailyLimit(String message) async {
    await notificationsPlugin.show(
      3,
      '🔔 Usage Alert',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'usage_limits',
          'Usage Limits',
          channelDescription: 'Daily usage limit notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  // Helper to calculate next daily time
  tz.TZDateTime _nextDailyTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}

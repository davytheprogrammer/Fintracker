import 'package:shared_preferences/shared_preferences.dart';

class DailyUsageManager {
  static Future<void> loadDailyUsage({
    required String key,
    required Function(int) onSuccess,
    required Function(Object) onError,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = prefs.getInt(key) ?? 0;
      onSuccess(count);
    } catch (e) {
      onError(e);
    }
  }

  static Future<void> incrementDailyUsage({
    required String key,
    required int currentCount,
    required Function(int) onSuccess,
    required Function(Object) onError,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final newCount = currentCount + 1;
      prefs.setInt(key, newCount);
      onSuccess(newCount);
    } catch (e) {
      onError(e);
    }
  }
}

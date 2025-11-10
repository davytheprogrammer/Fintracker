import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/gamification/streak_model.dart';
import 'gamification_service.dart';

class OfflineSyncService {
  static const String _pendingEventsKey = 'gamification_pending_events';
  static const Duration _syncInterval = Duration(minutes: 5);

  final GamificationService _gamificationService;
  final SharedPreferences _prefs;

  OfflineSyncService(this._gamificationService, this._prefs);

  // Queue gamification events when offline
  Future<void> queueEvent(
      String uid, String eventType, Map<String, dynamic> eventData) async {
    final pendingEvents = await _getPendingEvents();
    final event = {
      'uid': uid,
      'eventType': eventType,
      'eventData': eventData,
      'timestamp': DateTime.now().toIso8601String(),
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    pendingEvents.add(event);
    await _savePendingEvents(pendingEvents);
  }

  // Sync pending events when online
  Future<void> syncPendingEvents() async {
    // Simplified connectivity check - assume online for now
    // In production, add connectivity_plus dependency
    try {
      // Check if we can reach Firebase
      await FirebaseFirestore.instance.collection('test').limit(1).get();
    } catch (e) {
      return; // Offline
    }

    final pendingEvents = await _getPendingEvents();
    if (pendingEvents.isEmpty) return;

    final syncedEvents = <Map<String, dynamic>>[];

    for (final event in pendingEvents) {
      try {
        await _processEvent(event);
        syncedEvents.add(event);
      } catch (e) {
        print('Failed to sync event ${event['id']}: $e');
        // Keep failed events for retry
      }
    }

    // Remove synced events
    pendingEvents.removeWhere((event) => syncedEvents.contains(event));
    await _savePendingEvents(pendingEvents);
  }

  Future<void> _processEvent(Map<String, dynamic> event) async {
    final uid = event['uid'] as String;
    final eventType = event['eventType'] as String;
    final eventData = event['eventData'] as Map<String, dynamic>;

    switch (eventType) {
      case 'badge_check':
        await _gamificationService.checkAndAwardBadges(uid, eventData['action'],
            context: eventData['context']);
        break;
      case 'streak_update':
        await _gamificationService.updateStreaks(uid, eventData['action']);
        break;
      default:
        throw UnsupportedError('Unknown event type: $eventType');
    }
  }

  Future<List<Map<String, dynamic>>> _getPendingEvents() async {
    final eventsJson = _prefs.getString(_pendingEventsKey);
    if (eventsJson == null) return [];

    final List<dynamic> eventsData = jsonDecode(eventsJson);
    return eventsData.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<void> _savePendingEvents(List<Map<String, dynamic>> events) async {
    final eventsJson = jsonEncode(events);
    await _prefs.setString(_pendingEventsKey, eventsJson);
  }

  // Handle streak resets for missed days
  Future<void> handleStreakResets(String uid) async {
    try {
      // Simplified streak reset handling
      // In production, implement proper streak tracking
      print('Streak reset handling for user: $uid');
    } catch (e) {
      print('Error handling streak resets: $e');
    }
  }

  // Clean up old pending events (older than 7 days)
  Future<void> cleanupOldEvents() async {
    final pendingEvents = await _getPendingEvents();
    final cutoffDate = DateTime.now().subtract(const Duration(days: 7));

    final filteredEvents = pendingEvents.where((event) {
      final eventDate = DateTime.parse(event['timestamp']);
      return eventDate.isAfter(cutoffDate);
    }).toList();

    if (filteredEvents.length != pendingEvents.length) {
      await _savePendingEvents(filteredEvents);
    }
  }

  // Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    final pendingEvents = await _getPendingEvents();
    final lastSyncTime = _prefs.getString('gamification_last_sync');

    return {
      'pendingEventsCount': pendingEvents.length,
      'lastSyncTime':
          lastSyncTime != null ? DateTime.parse(lastSyncTime) : null,
      'isOnline': await _isOnline(),
    };
  }

  Future<bool> _isOnline() async {
    // Simplified online check - assume online for now
    // In production, add connectivity_plus dependency
    try {
      await FirebaseFirestore.instance.collection('test').limit(1).get();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Force sync (for manual sync)
  Future<void> forceSync() async {
    await syncPendingEvents();
    await _prefs.setString(
        'gamification_last_sync', DateTime.now().toIso8601String());
  }
}

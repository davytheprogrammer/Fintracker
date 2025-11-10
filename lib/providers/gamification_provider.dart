import 'package:flutter/foundation.dart';
import '../models/gamification/user_gamification_model.dart';
import '../services/gamification/gamification_service.dart';
import 'user_provider.dart';

class GamificationProvider with ChangeNotifier {
  final GamificationService _gamificationService = GamificationService();
  final UserProvider _userProvider;

  UserGamificationModel? _gamificationData;
  bool _isLoading = false;
  String? _error;

  GamificationProvider(this._userProvider) {
    _userProvider.addListener(_onUserChanged);
  }

  UserGamificationModel? get gamificationData => _gamificationData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _onUserChanged() {
    if (_userProvider.currentUser != null) {
      loadGamificationData();
    } else {
      _gamificationData = null;
      notifyListeners();
    }
  }

  Future<void> loadGamificationData() async {
    if (_userProvider.currentUser == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _gamificationData = await _gamificationService
          .getUserGamificationData(_userProvider.currentUser!.uid);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> onTransactionLogged() async {
    if (_userProvider.currentUser == null) return;

    try {
      await _gamificationService.checkAndAwardBadges(
        _userProvider.currentUser!.uid,
        'transaction_logged',
      );
      await _gamificationService.updateStreaks(
        _userProvider.currentUser!.uid,
        'transaction_logged',
      );
      await loadGamificationData(); // Refresh data
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> onGoalAchieved() async {
    if (_userProvider.currentUser == null) return;

    try {
      await _gamificationService.checkAndAwardBadges(
        _userProvider.currentUser!.uid,
        'goal_achieved',
      );
      await _gamificationService.updateStreaks(
        _userProvider.currentUser!.uid,
        'goal_achieved',
      );
      await loadGamificationData();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> onAnalyticsViewed() async {
    if (_userProvider.currentUser == null) return;

    try {
      await _gamificationService.updateStreaks(
        _userProvider.currentUser!.uid,
        'analytics_viewed',
      );
      await loadGamificationData();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> onBudgetChecked() async {
    if (_userProvider.currentUser == null) return;

    try {
      await _gamificationService.updateStreaks(
        _userProvider.currentUser!.uid,
        'budget_checked',
      );
      await loadGamificationData();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get badge progress for a specific badge
  int getBadgeProgress(String badgeId) {
    return _gamificationData?.getBadgeProgress(badgeId) ?? 0;
  }

  // Get streak count for a specific streak
  int getStreakCount(String streakId) {
    return _gamificationData?.getStreakCount(streakId) ?? 0;
  }

  // Check if user has a specific badge
  bool hasBadge(String badgeId) {
    return _gamificationData?.hasBadge(badgeId) ?? false;
  }

  // Check if streak is active
  bool isStreakActive(String streakId) {
    return _gamificationData?.isStreakActive(streakId) ?? false;
  }

  // Get total points
  int get totalPoints => _gamificationData?.totalPoints ?? 0;

  // Get badges unlocked count
  int get badgesUnlocked => _gamificationData?.unlockedBadges.length ?? 0;

  @override
  void dispose() {
    _userProvider.removeListener(_onUserChanged);
    super.dispose();
  }
}

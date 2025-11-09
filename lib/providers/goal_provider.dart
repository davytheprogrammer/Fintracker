import 'package:flutter/foundation.dart';
import '../models/goal_model.dart';
import '../repositories/goal_repository.dart';

enum GoalStatus { active, completed, overdue, all }

class GoalProvider with ChangeNotifier {
  final GoalRepository _goalRepository = GoalRepository();

  List<GoalModel> _goals = [];
  bool _isLoading = false;
  String? _errorMessage;
  GoalStatus _filterStatus = GoalStatus.all;

  // Getters
  List<GoalModel> get goals => _filteredGoals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  GoalStatus get filterStatus => _filterStatus;

  // Computed properties
  List<GoalModel> get _filteredGoals {
    switch (_filterStatus) {
      case GoalStatus.active:
        return _goals
            .where((goal) => !goal.isCompleted && !goal.isOverdue)
            .toList();
      case GoalStatus.completed:
        return _goals.where((goal) => goal.isCompleted).toList();
      case GoalStatus.overdue:
        return _goals.where((goal) => goal.isOverdue).toList();
      case GoalStatus.all:
        return _goals;
    }
  }

  int get totalGoals => _goals.length;
  int get activeGoals =>
      _goals.where((goal) => !goal.isCompleted && !goal.isOverdue).length;
  int get completedGoals => _goals.where((goal) => goal.isCompleted).length;
  int get overdueGoals => _goals.where((goal) => goal.isOverdue).length;

  double get totalTargetAmount =>
      _goals.fold(0.0, (sum, goal) => sum + goal.targetAmount);
  double get totalCurrentAmount =>
      _goals.fold(0.0, (sum, goal) => sum + goal.currentAmount);
  double get overallProgress => totalTargetAmount > 0
      ? (totalCurrentAmount / totalTargetAmount).clamp(0.0, 1.0)
      : 0.0;
  double get completionRate =>
      totalGoals > 0 ? (completedGoals / totalGoals) : 0.0;

  // Load goals for a user
  Future<void> loadGoals(String uid) async {
    _setLoading(true);
    try {
      _goals = await _goalRepository.getUserGoals(uid);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load goals: $e';
      _goals = [];
    } finally {
      _setLoading(false);
    }
  }

  // Create new goal
  Future<bool> createGoal(GoalModel goal) async {
    _setLoading(true);
    try {
      final id = await _goalRepository.createGoal(goal, goal.uid);
      final newGoal = goal.copyWith(id: id);
      _goals.add(newGoal);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create goal: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update existing goal
  Future<bool> updateGoal(GoalModel goal) async {
    if (goal.id == null) return false;

    _setLoading(true);
    try {
      await _goalRepository.updateGoal(goal.id!, goal, goal.uid);

      // Update in local list
      final index = _goals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        _goals[index] = goal;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update goal: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update goal progress
  Future<bool> updateGoalProgress(
      String goalId, String uid, double newAmount) async {
    _setLoading(true);
    try {
      await _goalRepository.updateGoalProgress(goalId, uid, newAmount);

      // Update in local list
      final index = _goals.indexWhere((g) => g.id == goalId);
      if (index != -1) {
        _goals[index] = _goals[index].copyWith(currentAmount: newAmount);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update goal progress: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Add to goal progress
  Future<bool> addToGoalProgress(
      String goalId, String uid, double amount) async {
    _setLoading(true);
    try {
      await _goalRepository.addToGoalProgress(goalId, uid, amount);

      // Update in local list
      final index = _goals.indexWhere((g) => g.id == goalId);
      if (index != -1) {
        final currentAmount = _goals[index].currentAmount;
        _goals[index] =
            _goals[index].copyWith(currentAmount: currentAmount + amount);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add to goal progress: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete goal
  Future<bool> deleteGoal(String goalId, String uid) async {
    _setLoading(true);
    try {
      await _goalRepository.deleteGoal(goalId, uid);

      // Remove from local list
      _goals.removeWhere((g) => g.id == goalId);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete goal: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get single goal
  Future<GoalModel?> getGoalById(String goalId, String uid) async {
    try {
      return await _goalRepository.getGoalById(goalId, uid);
    } catch (e) {
      _errorMessage = 'Failed to get goal: $e';
      return null;
    }
  }

  // Get goals by status
  Future<List<GoalModel>> getGoalsByStatus(String uid, String status) async {
    try {
      return await _goalRepository.getGoalsByStatus(uid, status);
    } catch (e) {
      _errorMessage = 'Failed to get goals by status: $e';
      return [];
    }
  }

  // Get goals nearing deadline
  Future<List<GoalModel>> getGoalsNearingDeadline(String uid,
      {int daysAhead = 30}) async {
    try {
      return await _goalRepository.getGoalsNearingDeadline(uid,
          daysAhead: daysAhead);
    } catch (e) {
      _errorMessage = 'Failed to get goals nearing deadline: $e';
      return [];
    }
  }

  // Get goal statistics
  Future<Map<String, dynamic>> getGoalStatistics(String uid) async {
    try {
      return await _goalRepository.getGoalStatistics(uid);
    } catch (e) {
      _errorMessage = 'Failed to get goal statistics: $e';
      return {};
    }
  }

  // Filter methods
  void setFilterStatus(GoalStatus status) {
    _filterStatus = status;
    notifyListeners();
  }

  void clearFilters() {
    _filterStatus = GoalStatus.all;
    notifyListeners();
  }

  // Utility methods for UI
  List<GoalModel> getCompletedGoals() =>
      _goals.where((goal) => goal.isCompleted).toList();

  List<GoalModel> getOverdueGoals() =>
      _goals.where((goal) => goal.isOverdue).toList();

  List<GoalModel> getActiveGoals() =>
      _goals.where((goal) => !goal.isCompleted && !goal.isOverdue).toList();

  List<GoalModel> getGoalsByProgressRange(
      double minProgress, double maxProgress) {
    return _goals
        .where((goal) =>
            goal.progressPercentage >= minProgress &&
            goal.progressPercentage <= maxProgress)
        .toList();
  }

  // Progress tracking methods
  double getAverageProgress() {
    if (_goals.isEmpty) return 0.0;
    final totalProgress =
        _goals.fold(0.0, (sum, goal) => sum + goal.progressPercentage);
    return totalProgress / _goals.length;
  }

  Map<String, int> getGoalsByMonth() {
    final Map<String, int> monthlyGoals = {};
    for (final goal in _goals) {
      final monthKey =
          '${goal.createdAt.year}-${goal.createdAt.month.toString().padLeft(2, '0')}';
      monthlyGoals[monthKey] = (monthlyGoals[monthKey] ?? 0) + 1;
    }
    return monthlyGoals;
  }

  List<Map<String, dynamic>> getProgressTrends({int months = 6}) {
    final now = DateTime.now();
    final trends = <Map<String, dynamic>>[];

    for (int i = months - 1; i >= 0; i--) {
      final monthStart = DateTime(now.year, now.month - i, 1);
      final monthEnd = DateTime(now.year, now.month - i + 1, 0);

      final monthGoals = _goals
          .where((goal) =>
              goal.createdAt.isAfter(monthStart) &&
              goal.createdAt.isBefore(monthEnd))
          .toList();

      final avgProgress = monthGoals.isNotEmpty
          ? monthGoals.fold(0.0, (sum, goal) => sum + goal.progressPercentage) /
              monthGoals.length
          : 0.0;

      trends.add({
        'month': monthStart,
        'goalCount': monthGoals.length,
        'averageProgress': avgProgress,
        'completedCount': monthGoals.where((goal) => goal.isCompleted).length,
      });
    }

    return trends;
  }

  // Sync goals
  Future<void> syncGoals(String uid) async {
    _setLoading(true);
    try {
      await _goalRepository.syncGoals(uid);
      // Reload goals after sync
      await loadGoals(uid);
    } catch (e) {
      _errorMessage = 'Failed to sync goals: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Utility methods
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Refresh goals data
  Future<void> refreshGoals(String uid) async {
    await loadGoals(uid);
  }
}

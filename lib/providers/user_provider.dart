import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

enum AuthState { unauthenticated, authenticating, authenticated, error }

class UserProvider with ChangeNotifier {
  final UserRepository _userRepository = UserRepository();

  AuthState _authState = AuthState.unauthenticated;
  UserModel? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthState get authState => _authState;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _authState == AuthState.authenticated;

  // Computed properties
  double get balance =>
      _currentUser != null ? 0.0 : 0.0; // Balance is stored in users table
  Currency? get currency => _currentUser?.currency;
  String? get currencySymbol => currency?.symbol ?? 'KES';
  String? get currencyCode => currency?.code ?? 'KES';

  // Authentication methods
  Future<void> signIn(String uid) async {
    _setLoading(true);
    _authState = AuthState.authenticating;
    notifyListeners();

    try {
      final user = await _userRepository.getUserByUid(uid);
      if (user != null) {
        _currentUser = user;
        _authState = AuthState.authenticated;
        _errorMessage = null;
      } else {
        _authState = AuthState.unauthenticated;
        _errorMessage = 'User not found';
      }
    } catch (e) {
      _authState = AuthState.error;
      _errorMessage = 'Sign in failed: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    _authState = AuthState.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  // Profile management methods
  Future<void> createOrUpdateProfile(UserModel user) async {
    _setLoading(true);
    try {
      await _userRepository.createOrUpdateUser(user);
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update profile: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? incomeRange,
    String? ageRange,
    String? occupation,
    String? country,
    String? city,
    String? riskTolerance,
    Currency? currency,
  }) async {
    if (_currentUser == null) return;

    _setLoading(true);
    try {
      await _userRepository.updateUserProfile(
        uid: _currentUser!.uid,
        name: name,
        email: email,
        incomeRange: incomeRange,
        ageRange: ageRange,
        occupation: occupation,
        country: country,
        city: city,
        riskTolerance: riskTolerance,
        currency: currency,
      );

      // Update local user model
      _currentUser = _currentUser!.copyWith(
        occupation: occupation,
        incomeRange: incomeRange,
        ageRange: ageRange,
        location: country != null && city != null
            ? Location(country: country, city: city)
            : _currentUser!.location,
        riskTolerance: riskTolerance,
        currency: currency ?? _currentUser!.currency,
      );

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update profile: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateGoals(List<String> goals) async {
    if (_currentUser == null) return;

    _setLoading(true);
    try {
      await _userRepository.updateUserGoals(_currentUser!.uid, goals);
      _currentUser = _currentUser!.copyWith(goals: goals);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update goals: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Data synchronization
  Future<void> syncUserData() async {
    if (_currentUser == null) return;

    _setLoading(true);
    try {
      // Clear cache to force fresh data
      await _userRepository.clearAllCaches();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to sync data: $e';
      notifyListeners();
      rethrow;
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

  // Refresh user data
  Future<void> refreshUserData() async {
    if (_currentUser == null) return;

    _setLoading(true);
    try {
      final updatedUser = await _userRepository.getUserByUid(_currentUser!.uid);
      if (updatedUser != null) {
        _currentUser = updatedUser;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to refresh user data: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }
}

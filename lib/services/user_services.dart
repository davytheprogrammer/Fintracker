// user_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Finspense/models/user_model.dart';
import 'package:Finspense/repositories/user_repository.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepository = UserRepository();

  // Get current user data
  Future<UserModel> getCurrentUserData() async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    UserModel? userModel = await _userRepository.getUserByUid(user.uid);

    if (userModel == null) {
      // Create new user data if it doesn't exist
      final newUser = UserModel(
        uid: user.uid,
        goals: [],
        currency: Currency(code: 'KES', symbol: 'KES'),
        incomeRange: 'Not specified',
        ageRange: 'Not specified',
        occupation: 'Not specified',
        location: Location(country: 'Kenya', city: 'Nairobi'),
        riskTolerance: 'Moderate',
      );
      await _userRepository.createOrUpdateUser(newUser);
      return newUser;
    }

    return userModel;
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? email,
    String? photoURL,
  }) async {
    await _userRepository.updateUserProfile(
      uid: uid,
      name: displayName,
      email: email,
    );
  }

  // Record relapse and reset streak
  Future<void> recordRelapse(String uid) async {
    // Note: This method is deprecated
    // Relapse tracking is not implemented in the UserRepository
    // This method is kept for backward compatibility
    throw UnimplementedError(
        'Relapse tracking is not supported in the repository pattern');
  }

  // Update streak days
  Future<void> updateStreakDays(String uid, int streakDays) async {
    // Note: This method is deprecated
    // Streak tracking is not implemented in the UserRepository
    // This method is kept for backward compatibility
    throw UnimplementedError(
        'Streak tracking is not supported in the repository pattern');
  }

  // Add support contact
  Future<void> addSupportContact(String uid, String contactInfo) async {
    // Note: Support network is not implemented in the UserRepository
    // This method is kept for backward compatibility
    throw UnimplementedError(
        'Support network is not supported in the repository pattern');
  }

  // Remove support contact
  Future<void> removeSupportContact(String uid, String contactInfo) async {
    // Note: Support network is not implemented in the UserRepository
    // This method is kept for backward compatibility
    throw UnimplementedError(
        'Support network is not supported in the repository pattern');
  }

  // Add emergency contact
  Future<void> addEmergencyContact(String uid, String contactInfo) async {
    // Note: Emergency contacts are not implemented in the UserRepository
    // This method is kept for backward compatibility
    throw UnimplementedError(
        'Emergency contacts are not supported in the repository pattern');
  }

  // Remove emergency contact
  Future<void> removeEmergencyContact(String uid, String contactInfo) async {
    // Note: Emergency contacts are not implemented in the UserRepository
    // This method is kept for backward compatibility
    throw UnimplementedError(
        'Emergency contacts are not supported in the repository pattern');
  }

  // Set or update goal
  Future<void> setGoal(
    String uid,
    String goalId,
    Map<String, dynamic> goalData,
  ) async {
    // Note: Goals are handled differently in the UserRepository
    // This method is kept for backward compatibility but goals are now stored as a list
    throw UnimplementedError(
        'Goals are now handled through UserRepository.updateUserGoals');
  }

  // Remove goal
  Future<void> removeGoal(String uid, String goalId) async {
    // Note: Goals are handled differently in the UserRepository
    // This method is kept for backward compatibility but goals are now stored as a list
    throw UnimplementedError(
        'Goals are now handled through UserRepository.updateUserGoals');
  }

  // Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    // Note: Email lookup is not implemented in the UserRepository
    // This method is kept for backward compatibility
    throw UnimplementedError(
        'Email lookup is not supported in the repository pattern');
  }

  // Calculate current streak
  Future<void> calculateAndUpdateStreak(String uid) async {
    // Note: Streak calculation is not implemented in the UserRepository
    // This method is kept for backward compatibility
    throw UnimplementedError(
        'Streak calculation is not supported in the repository pattern');
  }

  // Stream user data for real-time updates
  Stream<UserModel> streamUserData(String uid) {
    // Note: Real-time streaming is not implemented in the UserRepository
    // This method is kept for backward compatibility
    throw UnimplementedError(
        'Real-time streaming is not supported in the repository pattern');
  }
}

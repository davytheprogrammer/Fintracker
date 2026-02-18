// user_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:Finspense/models/user_model.dart';
import 'package:Finspense/repositories/user_repository.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepository = UserRepository();

  /// Get current user data, creating a default profile if none exists.
  Future<UserModel> getCurrentUserData() async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    UserModel? userModel = await _userRepository.getUserByUid(user.uid);

    if (userModel == null) {
      final newUser = UserModel(
        uid: user.uid,
        displayName: user.displayName,
        email: user.email,
        photoURL: user.photoURL,
        goals: [],
        currency: Currency(code: 'KES', symbol: 'KES'),
        incomeRange: 'Not specified',
        ageRange: 'Not specified',
        occupation: 'Not specified',
        location: Location(country: 'Kenya', city: 'Nairobi'),
        riskTolerance: 'Moderate',
        createdAt: DateTime.now(),
      );
      await _userRepository.createOrUpdateUser(newUser);
      return newUser;
    }

    return userModel;
  }

  /// Update user profile fields.
  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? email,
    String? photoURL,
  }) async {
    try {
      await _userRepository.updateUserProfile(
        uid: uid,
        name: displayName,
        email: email,
      );
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }
}

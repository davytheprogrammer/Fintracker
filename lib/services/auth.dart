import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:Finspense/models/the_user.dart';
import 'package:Finspense/repositories/user_repository.dart';
import 'package:Finspense/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Convert Firebase User to TheUser.
  TheUser? _userFromFirebaseUser(User? user) {
    return user != null
        ? TheUser(
            uid: user.uid,
            email: user.email,
            displayName: user.displayName,
          )
        : null;
  }

  /// Auth state change stream.
  Stream<TheUser?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  /// Sign in anonymously.
  Future<TheUser?> signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      return _userFromFirebaseUser(result.user);
    } catch (e) {
      debugPrint('Error signing in anonymously: $e');
      return null;
    }
  }

  /// Sign in with email and password.
  /// Returns the user on success, null on failure.
  /// Throws [FirebaseAuthException] for specific error handling by the UI.
  Future<TheUser?> signInWithEmailAndPassword(
      String email, String password) async {
    final trimmedEmail = email.trim().toLowerCase();

    if (trimmedEmail.isEmpty || password.isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-input',
        message: 'Email and password are required.',
      );
    }

    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
      return _userFromFirebaseUser(result.user);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      debugPrint('Error signing in: $e');
      return null;
    }
  }

  /// Register a new user with email and password.
  /// Creates a Firestore user profile on successful registration.
  Future<TheUser?> registerWithEmailAndPassword(
    String displayName,
    String email,
    String password,
  ) async {
    final trimmedEmail = email.trim().toLowerCase();
    final trimmedName = displayName.trim();

    if (trimmedEmail.isEmpty || password.isEmpty || trimmedName.isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-input',
        message: 'All fields are required.',
      );
    }

    if (password.length < 8) {
      throw FirebaseAuthException(
        code: 'weak-password',
        message: 'Password must be at least 8 characters.',
      );
    }

    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );

      User? user = result.user;
      if (user == null) return null;

      // Set display name on Firebase user
      await user.updateDisplayName(trimmedName);

      // Create user profile in Firestore
      final userRepository = UserRepository();
      await userRepository.createOrUpdateUser(UserModel(
        uid: user.uid,
        displayName: trimmedName,
        email: trimmedEmail,
        goals: [],
        currency: Currency(code: 'KES', symbol: 'KES'),
        incomeRange: 'Not specified',
        ageRange: 'Not specified',
        occupation: 'Not specified',
        location: Location(country: 'Kenya', city: 'Nairobi'),
        riskTolerance: 'Moderate',
        createdAt: DateTime.now(),
      ));

      return _userFromFirebaseUser(user);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      debugPrint('Error registering: $e');
      return null;
    }
  }

  /// Send password reset email.
  Future<void> resetPassword(String email) async {
    final trimmedEmail = email.trim().toLowerCase();

    if (trimmedEmail.isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'Please enter your email address.',
      );
    }

    try {
      await _auth.sendPasswordResetEmail(email: trimmedEmail);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      debugPrint('Error sending password reset email: $e');
      rethrow;
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }
}

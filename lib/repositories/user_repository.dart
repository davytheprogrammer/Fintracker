import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserRepository {
  static UserRepository? _instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserRepository._privateConstructor();
  factory UserRepository() {
    _instance ??= UserRepository._privateConstructor();
    return _instance!;
  }

  static const String _cacheKeyPrefix = 'user_cache_';
  static const String _cacheTimestampPrefix = 'user_cache_timestamp_';
  static const Duration _cacheExpiry = Duration(hours: 1);

  String _getCacheKey(String uid) => '$_cacheKeyPrefix$uid';
  String _getTimestampKey(String uid) => '$_cacheTimestampPrefix$uid';

  Future<void> _cacheUserData(String uid, UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      await prefs.setString(_getCacheKey(uid), userJson);
      await prefs.setInt(
          _getTimestampKey(uid), DateTime.now().millisecondsSinceEpoch);
      debugPrint('User data cached for $uid');
    } catch (e) {
      debugPrint('Failed to cache user data: $e');
    }
  }

  Future<UserModel?> _getCachedUserData(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_getCacheKey(uid));
      final timestamp = prefs.getInt(_getTimestampKey(uid));

      if (cachedJson != null && timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cacheTime) < _cacheExpiry) {
          final data = jsonDecode(cachedJson) as Map<String, dynamic>;
          debugPrint('Retrieved cached user data for $uid');
          return UserModel.fromJson(data, uid: uid);
        }
      }
    } catch (e) {
      debugPrint('Failed to retrieve cached user data: $e');
    }
    return null;
  }

  Future<void> _clearCache(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_getCacheKey(uid));
      await prefs.remove(_getTimestampKey(uid));
    } catch (e) {
      debugPrint('Failed to clear cache: $e');
    }
  }

  Future<void> createOrUpdateUser(UserModel user) async {
    try {
      if (user.uid.isEmpty) throw Exception('User UID cannot be empty');

      await _firestore.collection('users').doc(user.uid).set(
            user.toFirestore(),
            SetOptions(merge: true),
          );

      await _cacheUserData(user.uid, user);
      debugPrint('User profile saved to Firestore');
    } catch (e) {
      throw Exception('Failed to create/update user profile: $e');
    }
  }

  Future<UserModel?> getUserByUid(String uid) async {
    try {
      final cachedUser = await _getCachedUserData(uid);
      if (cachedUser != null) return cachedUser;

      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;

      final user = UserModel.fromFirestore(doc);
      await _cacheUserData(uid, user);
      return user;
    } catch (e) {
      throw Exception('Failed to retrieve user data: $e');
    }
  }

  Future<void> updateUserProfile({
    required String uid,
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
    try {
      if (uid.isEmpty) throw Exception('User UID cannot be empty');

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (email != null) updates['email'] = email;
      if (incomeRange != null) updates['incomeRange'] = incomeRange;
      if (ageRange != null) updates['ageRange'] = ageRange;
      if (occupation != null) updates['occupation'] = occupation;
      if (country != null || city != null) {
        updates['location'] = {
          if (country != null) 'country': country,
          if (city != null) 'city': city,
        };
      }
      if (riskTolerance != null) updates['riskTolerance'] = riskTolerance;
      if (currency != null) {
        updates['currency'] = {
          'code': currency.code,
          'symbol': currency.symbol
        };
      }

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(uid).update(updates);
        await _clearCache(uid);
      }
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  Future<void> updateUserGoals(String uid, List<String> goals) async {
    try {
      await _firestore.collection('users').doc(uid).update({'goals': goals});
      await _clearCache(uid);
    } catch (e) {
      throw Exception('Failed to update user goals: $e');
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      if (uid.isEmpty) throw Exception('User UID cannot be empty');
      await _firestore.collection('users').doc(uid).delete();
      await _clearCache(uid);
    } catch (e) {
      throw Exception('Failed to delete user data: $e');
    }
  }

  Stream<UserModel?> streamUserData(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      final user = UserModel.fromFirestore(doc);
      _cacheUserData(uid, user);
      return user;
    });
  }

  Future<void> clearAllCaches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_cacheKeyPrefix) ||
            key.startsWith(_cacheTimestampPrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      debugPrint('Failed to clear all caches: $e');
    }
  }
}

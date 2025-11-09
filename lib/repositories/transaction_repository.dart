import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  static TransactionRepository? _instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TransactionRepository._privateConstructor();
  factory TransactionRepository() {
    _instance ??= TransactionRepository._privateConstructor();
    return _instance!;
  }

  static const String _cacheKeyPrefix = 'transactions_cache_';
  static const String _cacheTimestampPrefix = 'transactions_cache_timestamp_';
  static const Duration _cacheExpiry = Duration(minutes: 30);

  String _getCacheKey(String uid) => '$_cacheKeyPrefix$uid';
  String _getTimestampKey(String uid) => '$_cacheTimestampPrefix$uid';

  Future<void> _cacheTransactions(
      String uid, List<TransactionModel> transactions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson =
          jsonEncode(transactions.map((t) => t.toMap()).toList());
      await prefs.setString(_getCacheKey(uid), transactionsJson);
      await prefs.setInt(
          _getTimestampKey(uid), DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Failed to cache transactions: $e');
    }
  }

  Future<List<TransactionModel>?> _getCachedTransactions(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_getCacheKey(uid));
      final timestamp = prefs.getInt(_getTimestampKey(uid));

      if (cachedJson != null && timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cacheTime) < _cacheExpiry) {
          final List<dynamic> data = jsonDecode(cachedJson);
          return data.map((t) => TransactionModel.fromMap(t)).toList();
        }
      }
    } catch (e) {
      debugPrint('Failed to retrieve cached transactions: $e');
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

  Future<String> addTransaction(TransactionModel transaction) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(transaction.uid)
          .collection('transactions')
          .add(transaction.toMap());
      await _clearCache(transaction.uid);
      debugPrint('Transaction added to Firestore');
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  Future<List<TransactionModel>> getTransactions({
    required String uid,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    String? type,
    int? limit,
  }) async {
    try {
      final cached = await _getCachedTransactions(uid);
      if (cached != null &&
          startDate == null &&
          endDate == null &&
          category == null &&
          type == null) {
        return cached;
      }

      Query query =
          _firestore.collection('users').doc(uid).collection('transactions');

      if (startDate != null) {
        query = query.where('date',
            isGreaterThanOrEqualTo: startDate.toIso8601String());
      }
      if (endDate != null) {
        query =
            query.where('date', isLessThanOrEqualTo: endDate.toIso8601String());
      }
      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }
      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }

      query = query.orderBy('date', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      final transactions = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return TransactionModel.fromMap(data);
      }).toList();

      if (startDate == null &&
          endDate == null &&
          category == null &&
          type == null) {
        await _cacheTransactions(uid, transactions);
      }

      return transactions;
    } catch (e) {
      throw Exception('Failed to get transactions: $e');
    }
  }

  Future<void> updateTransaction(
      String transactionId, TransactionModel transaction, String uid) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .doc(transactionId)
          .update(transaction.toMap());
      await _clearCache(uid);
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  Future<void> deleteTransaction(String transactionId, String uid) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .doc(transactionId)
          .delete();
      await _clearCache(uid);
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  Stream<List<TransactionModel>> streamTransactions(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      final transactions = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return TransactionModel.fromMap(data);
      }).toList();
      _cacheTransactions(uid, transactions);
      return transactions;
    });
  }

  Future<Map<String, dynamic>> getTransactionSummary({
    required String uid,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final transactions = await getTransactions(
        uid: uid,
        startDate: startDate,
        endDate: endDate,
      );

      double totalIncome = 0.0;
      double totalExpense = 0.0;
      Map<String, double> categoryIncome = {};
      Map<String, double> categoryExpense = {};

      for (final transaction in transactions) {
        if (transaction.type == 'income') {
          totalIncome += transaction.amount;
          categoryIncome[transaction.category] =
              (categoryIncome[transaction.category] ?? 0) + transaction.amount;
        } else {
          totalExpense += transaction.amount;
          categoryExpense[transaction.category] =
              (categoryExpense[transaction.category] ?? 0) + transaction.amount;
        }
      }

      return {
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'netAmount': totalIncome - totalExpense,
        'transactionCount': transactions.length,
        'categoryIncome': categoryIncome,
        'categoryExpense': categoryExpense,
      };
    } catch (e) {
      throw Exception('Failed to get transaction summary: $e');
    }
  }

  Future<TransactionModel?> getTransactionById(
      String transactionId, String uid) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .doc(transactionId)
          .get();
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return TransactionModel.fromMap(data);
    } catch (e) {
      throw Exception('Failed to get transaction: $e');
    }
  }

  Future<double> getUserBalance(String uid) async {
    try {
      final summary = await getTransactionSummary(uid: uid);
      return summary['netAmount'] as double;
    } catch (e) {
      throw Exception('Failed to get user balance: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCategories({String? type}) async {
    try {
      // For now, return hardcoded categories. In a real app, this would be stored in Firestore
      final categories = [
        {'name': 'Food', 'type': 'expense', 'icon': 'restaurant'},
        {'name': 'Transport', 'type': 'expense', 'icon': 'directions_car'},
        {'name': 'Entertainment', 'type': 'expense', 'icon': 'movie'},
        {'name': 'Shopping', 'type': 'expense', 'icon': 'shopping_cart'},
        {'name': 'Bills', 'type': 'expense', 'icon': 'receipt'},
        {'name': 'Salary', 'type': 'income', 'icon': 'work'},
        {'name': 'Freelance', 'type': 'income', 'icon': 'computer'},
        {'name': 'Investment', 'type': 'income', 'icon': 'trending_up'},
      ];

      if (type != null) {
        return categories.where((cat) => cat['type'] == type).toList();
      }
      return categories;
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  Future<void> addCategory(String name, String type, {String? icon}) async {
    try {
      // For now, just log. In a real app, this would save to Firestore
      debugPrint('Category added: $name, $type, $icon');
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

  Future<void> syncTransactions(String uid) async {
    try {
      // Clear cache to force fresh data
      await _clearCache(uid);
      debugPrint('Transactions synced for user: $uid');
    } catch (e) {
      throw Exception('Failed to sync transactions: $e');
    }
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

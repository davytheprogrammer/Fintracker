import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  // Singleton instance
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get _currentUser => _auth.currentUser;

  // Store transaction data in Firestore
  Future<void> storeTransactionData({
    required String type,
    required String category,
    required double amount,
    required String description,
    required DateTime date,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }

    try {
      await _firestore.collection('transactions').add({
        'userId': user.uid,
        'type': type,
        'category': category,
        'amount': amount,
        'description': description,
        'date': Timestamp.fromDate(date),
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Transaction data stored successfully.');
    } catch (e) {
      debugPrint('Error storing transaction data: $e');
      throw Exception('Failed to store transaction data.');
    }
  }

  // Fetch user transactions from Firestore
  Future<List<Map<String, dynamic>>> getUserTransactions() async {
    final user = _currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }

    try {
      final querySnapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      throw Exception('Failed to fetch transactions.');
    }
  }

  // Delete a transaction by ID
  Future<void> deleteTransaction(String transactionId) async {
    final user = _currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }

    try {
      await _firestore.collection('transactions').doc(transactionId).delete();
      debugPrint('Transaction deleted successfully.');
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      throw Exception('Failed to delete transaction.');
    }
  }

  // Update a transaction by ID
  Future<void> updateTransaction({
    required String transactionId,
    required String type,
    required String category,
    required double amount,
    required String description,
    required DateTime date,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }

    try {
      await _firestore.collection('transactions').doc(transactionId).update({
        'type': type,
        'category': category,
        'amount': amount,
        'description': description,
        'date': Timestamp.fromDate(date),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Transaction updated successfully.');
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      throw Exception('Failed to update transaction.');
    }
  }
}

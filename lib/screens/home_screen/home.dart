import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'widgets/balance_card.dart';
import 'widgets/expense_chart.dart';
import 'widgets/recent_transactions.dart';
import 'widgets/budget_progress.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double _totalBalance = 0;
  double _totalIncome = 0;
  double _totalExpenses = 0;
  String _currencyCode = 'KSh';
  String _currencySymbol = 'KES';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _ensureTransactionsCollection(user.uid);
      await _loadUserPreferences();
    }
  }

  Future<void> _ensureTransactionsCollection(String userId) async {
    final transactionsRef = _firestore.collection('transactions');
    final snapshot = await transactionsRef.where('userId', isEqualTo: userId).limit(1).get();

    if (snapshot.docs.isEmpty) {
      await transactionsRef.add({
        'userId': userId,
        'amount': 0,
        'type': 'income',
        'date': DateTime.now(),
      });
    }
  }

  Future<void> _loadUserPreferences() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists && mounted) {
          setState(() {
            _currencyCode = userDoc['currency']['code'] ?? 'KSh';
            _currencySymbol = userDoc['currency']['symbol'] ?? 'KES';
          });
        }
      }
    } catch (e) {
      print('Error loading user preferences: $e');
    }
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      symbol: _currencySymbol,
      decimalDigits: 2,
    ).format(amount);
  }

  Future<void> _refreshData() async {
    await _loadUserPreferences();
    if (mounted) setState(() {});
  }

  void _calculateTotals(List<QueryDocumentSnapshot> transactions) {
    double totalIncome = 0;
    double totalExpenses = 0;

    for (var transaction in transactions) {
      final data = transaction.data() as Map<String, dynamic>;
      if (data['type'] == 'income') {
        totalIncome += data['amount'];
      } else if (data['type'] == 'expense') {
        totalExpenses += data['amount'];
      }
    }

    _totalIncome = totalIncome;
    _totalExpenses = totalExpenses;
    _totalBalance = totalIncome - totalExpenses;
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    return Scaffold(
      backgroundColor: Colors.white, // Base background color
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFF06292), // Light pink
                const Color(0xFFE91E63), // Darker pink
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 2),
                blurRadius: 6.0,
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'My Finance',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Welcome back${user != null ? ', ' + (user.displayName ?? 'User') : ''}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                        onPressed: () {
                          // Handle notifications
                        },
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: user?.photoURL != null
                              ? Image.network(user!.photoURL!, fit: BoxFit.cover)
                              : const Icon(Icons.person, color: Color(0xFFE91E63)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: user != null
              ? _firestore
              .collection('transactions')
              .where('userId', isEqualTo: user.uid)
              .orderBy('date', descending: true)
              .snapshots()
              : null,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/empty_state.png', height: 150), // Add an illustration
                    const SizedBox(height: 16),
                    const Text(
                      'No transactions found.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to add transaction screen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E63), // Pink color
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Add Transaction', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }

            final transactions = snapshot.data!.docs;
            _calculateTotals(transactions);

            return RefreshIndicator(
              onRefresh: _refreshData,
              color: const Color(0xFFE91E63), // Pink color
              backgroundColor: Colors.white,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  BalanceCard(
                    totalBalance: _totalBalance,
                    totalIncome: _totalIncome,
                    totalExpenses: _totalExpenses,
                    isLoading: snapshot.connectionState == ConnectionState.waiting,
                    formatCurrency: _formatCurrency,
                  ),
                  ExpenseChart(
                    transactions: transactions.map((doc) => doc.data() as Map<String, dynamic>).toList(),
                    formatCurrency: _formatCurrency,
                  ),
                  RecentTransactions(
                    transactions: transactions.map((doc) => doc.data() as Map<String, dynamic>).toList(),
                    formatCurrency: _formatCurrency,
                  ),
                  BudgetProgress(
                    totalIncome: _totalIncome,
                    totalExpenses: _totalExpenses,
                    formatCurrency: _formatCurrency,
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
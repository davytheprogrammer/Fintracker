import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import '../form/transaction_modal.dart';
import 'widgets/balance_card.dart';
import 'widgets/expense_chart.dart';
import 'widgets/floating.dart';
import 'widgets/recent_transactions.dart';
import 'widgets/budget_progress.dart';

// Custom color scheme for the app
class AppColors {
  static const primaryPink = Color(0xFFFF80AB); // Light pink
  static const secondaryPink = Color(0xFFFCE4EC); // Very light pink
  static const accentPink = Color(0xFFF48FB1); // Medium pink
  static const backgroundPink = Color(0xFFFFF5F8); // Subtle pink background
  static const errorRed = Color(0xFFFF5252);
  static const successGreen = Color(0xFF4CAF50);

  // Gradient colors
  static const gradientStart = Color(0xFFFCE4EC); // Very light pink
  static const gradientEnd = Color(0xFFF8BBD0); // Slightly darker pink
}

class HomePageException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const HomePageException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'HomePageException: $message (Code: $code)';
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final ValueNotifier<_FinanceData> _financeData;
  late final ValueNotifier<_UserPreferences> _userPrefs;
  late final ValueNotifier<bool> _isLoading;
  late final ValueNotifier<String?> _error;
  late final ScrollController _scrollController;
  late final AnimationController _fabAnimationController;
  late final Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeNotifiers();
    _initializeAnimations();
    _initializeData();
  }

  void _initializeControllers() {
    _scrollController = ScrollController();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  void _initializeAnimations() {
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
  }

  void _initializeNotifiers() {
    _financeData = ValueNotifier<_FinanceData>(
      const _FinanceData(
        totalBalance: 0,
        totalIncome: 0,
        totalExpenses: 0,
      ),
    );

    _userPrefs = ValueNotifier<_UserPreferences>(
      const _UserPreferences(
        currencyCode: 'KSh',
        currencySymbol: 'KES',
      ),
    );

    _isLoading = ValueNotifier<bool>(true);
    _error = ValueNotifier<String?>(null);
  }

  Future<void> _initializeData() async {
    try {
      _isLoading.value = true;
      _error.value = null;

      final user = _auth.currentUser;
      if (user == null)
        throw const HomePageException('No authenticated user', code: 'NO_USER');

      await Future.wait([
        _ensureTransactionsCollection(user.uid),
        _loadUserPreferences(user.uid),
      ]);

      _fabAnimationController.forward();
    } catch (e, stackTrace) {
      debugPrint('Initialization error: $e\n$stackTrace');
      _error.value = 'Failed to initialize app data';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _ensureTransactionsCollection(String userId) async {
    try {
      final transactionsRef = _firestore.collection('transactions');
      final snapshot = await transactionsRef
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        await transactionsRef.add({
          'userId': userId,
          'amount': 0,
          'type': 'income',
          'date': DateTime.now(),
          'description': 'Initial setup',
          'category': 'other',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw HomePageException(
        'Failed to initialize transactions',
        code: 'INIT_TRANS_FAILED',
        originalError: e,
      );
    }
  }

  Future<void> _loadUserPreferences(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        await _firestore.collection('users').doc(userId).set({
          'currency': {
            'code': 'KSh',
            'symbol': 'KES',
          },
          'createdAt': FieldValue.serverTimestamp(),
        });
        return;
      }

      if (!mounted) return;

      final data = userDoc.data() as Map<String, dynamic>;
      _userPrefs.value = _UserPreferences(
        currencyCode: data['currency']?['code'] ?? 'KSh',
        currencySymbol: data['currency']?['symbol'] ?? 'KES',
      );
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  void _calculateTotals(List<QueryDocumentSnapshot> transactions) {
    try {
      double totalIncome = 0;
      double totalExpenses = 0;

      for (var transaction in transactions) {
        final data = transaction.data() as Map<String, dynamic>;
        final amount = (data['amount'] as num).toDouble();

        if (data['type'] == 'income') {
          totalIncome += amount;
        } else if (data['type'] == 'expense') {
          totalExpenses += amount;
        }
      }

      _financeData.value = _FinanceData(
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        totalBalance: totalIncome - totalExpenses,
      );
    } catch (e, stackTrace) {
      debugPrint('Error calculating totals: $e\n$stackTrace');
      _financeData.value = const _FinanceData(
        totalIncome: 0,
        totalExpenses: 0,
        totalBalance: 0,
      );
    }
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      symbol: _userPrefs.value.currencySymbol,
      decimalDigits: 2,
    ).format(amount);
  }

  Future<void> _refreshData() async {
    try {
      HapticFeedback.selectionClick();
      await _loadUserPreferences(_auth.currentUser?.uid ?? '');
      setState(() {});
    } catch (e) {
      _showErrorSnackBar('Failed to refresh data');
    }
  }

  Future<void> _showAddTransactionSheet(bool isIncome) async {
    try {
      HapticFeedback.mediumImpact();

      final result = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => TransactionFormPage(isIncome: isIncome),
      );

      if (result == true) {
        _showSuccessSnackBar(isIncome
            ? 'Income added successfully'
            : 'Expense added successfully');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to add transaction');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: AppColors.errorRed,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: AppColors.successGreen,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: FadeTransition(
        opacity: _fabAnimation,
        child: ScaleTransition(
          scale: _fabAnimation,
          child: TransactionFAB(
            onTransactionSelected: _showAddTransactionSheet,
            onAnalyticsPressed: () {
              // TODO: Implement analytics
              debugPrint('Analytics pressed');
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final user = _auth.currentUser;

    return PreferredSize(
      preferredSize: const Size.fromHeight(80.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.gradientStart,
              AppColors.gradientEnd,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAppBarTitle(user),
                _buildAppBarActions(user),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarTitle(User? user) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(8.0),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            color: AppColors.primaryPink,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'FinSpense',
              style: TextStyle(
                color: AppColors.primaryPink,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Welcome back${user != null ? ', ${user.displayName ?? 'User'}' : ''}',
              style: TextStyle(
                color: AppColors.primaryPink.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppBarActions(User? user) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppColors.primaryPink,
            size: 28,
          ),
          onPressed: () {
            // TODO: Implement notifications
            debugPrint('Notifications pressed');
          },
        ),
        const SizedBox(width: 8),
        _buildProfileAvatar(user),
      ],
    );
  }

  Widget _buildProfileAvatar(User? user) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPink.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: user?.photoURL != null
            ? Image.network(
                user!.photoURL!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.person,
                    color: AppColors.primaryPink,
                  );
                },
              )
            : Icon(
                Icons.person,
                color: AppColors.primaryPink,
              ),
      ),
    );
  }

  Widget _buildBody() {
    final user = _auth.currentUser;

    if (user == null) {
      return Center(
        child: Text(
          'Please sign in to continue',
          style: TextStyle(color: AppColors.primaryPink),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        final transactions = snapshot.data!.docs;
        _calculateTotals(transactions);

        return _buildTransactionList(transactions);
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.errorRed,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primaryPink,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryPink.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPink,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPink),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/empty_state.png',
            height: 150,
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primaryPink,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your first transaction',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryPink.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showAddTransactionSheet(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPink,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: const Text(
              'Add Transaction',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<QueryDocumentSnapshot> transactions) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppColors.primaryPink,
      backgroundColor: Colors.white,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        children: [
          BalanceCard(
            totalBalance: _financeData.value.totalBalance,
            totalIncome: _financeData.value.totalIncome,
            totalExpenses: _financeData.value.totalExpenses,
            isLoading: false,
            formatCurrency: _formatCurrency,
          ),
          ExpenseChart(
            transactions: transactions
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList(),
            formatCurrency: _formatCurrency,
          ),
          RecentTransactions(
            transactions: transactions
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList(),
            formatCurrency: _formatCurrency,
          ),
          BudgetProgress(
            totalIncome: _financeData.value.totalIncome,
            totalExpenses: _financeData.value.totalExpenses,
            formatCurrency: _formatCurrency,
          ),
          const SizedBox(height: 100), // Space for FAB
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabAnimationController.dispose();
    _financeData.dispose();
    _userPrefs.dispose();
    _isLoading.dispose();
    _error.dispose();
    super.dispose();
  }
}

class _FinanceData {
  final double totalBalance;
  final double totalIncome;
  final double totalExpenses;

  const _FinanceData({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpenses,
  });
}

class _UserPreferences {
  final String currencyCode;
  final String currencySymbol;

  const _UserPreferences({
    required this.currencyCode,
    required this.currencySymbol,
  });
}

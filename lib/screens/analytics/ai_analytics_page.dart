import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/ai_service.dart';

import '../../models/user_model.dart';
import '../../services/user_services.dart';
import 'financial_summary_card.dart';
import 'ai_insight_card.dart';
import 'category_donut_chart.dart';
import 'spending_trend_card.dart';

class AIAnalyticsPage extends StatefulWidget {
  const AIAnalyticsPage({Key? key}) : super(key: key);

  @override
  _AIAnalyticsPageState createState() => _AIAnalyticsPageState();
}

class _AIAnalyticsPageState extends State<AIAnalyticsPage>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();
  final AIService _aiService = AIService();
  final String _prefsKeyInsights = 'ai_financial_insights';
  final String _prefsKeyTimestamp = 'ai_insights_timestamp';

  // User profile data
  UserModel? _userModel;

  // Financial data variables
  String _aiInsight = 'Analyzing your financial patterns...';
  bool _isLoadingAIInsight = true;
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _monthlyData = [];

  // Financial summaries
  double _totalIncome = 0;
  double _totalExpenses = 0;
  double _netSavings = 0;
  final Map<String, double> _categorySpending = {};
  int _selectedCategoryIndex = -1;

  // Animation and UI controllers
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isFetchingData = false;

  // Chart colors
  final List<Color> _categoryColors = [
    const Color(0xFF673AB7),
    const Color(0xFF9C27B0),
    const Color(0xFFB39DDB),
    const Color(0xFFD1C4E9),
    const Color(0xFFE1BEE7),
    const Color(0xFF3F51B5),
    const Color(0xFF2196F3),
    const Color(0xFF4CAF50),
    const Color(0xFF8BC34A),
    const Color(0xFFFFC107),
    const Color(0xFFFF9800),
    const Color(0xFFFF5722),
    const Color(0xFF795548),
    const Color(0xFF607D8B),
    const Color(0xFF9E9E9E),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutQuart,
    );
    _animationController.forward();

    _initializeData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    if (!mounted) return;
    setState(() {
      _isFetchingData = true;
    });

    await _loadCachedInsights();
    if (!mounted) return;

    await _loadUserProfile();
    if (!mounted) return;

    // Note: We no longer call _fetchTransactionsAndAnalyze here
    // as the StreamBuilder in _buildAnalyticsContent will handle real-time updates

    if (!mounted) return;
    setState(() {
      _isFetchingData = false;
    });
  }

  Future<void> _loadCachedInsights() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedInsight = prefs.getString(_prefsKeyInsights);
      final cachedTimestamp = prefs.getInt(_prefsKeyTimestamp);

      if (cachedInsight != null && cachedTimestamp != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final hourDiff = (now - cachedTimestamp) / (1000 * 60 * 60);

        // If cached insights are less than 12 hours old, use them
        if (hourDiff < 12) {
          if (!mounted) return;
          setState(() {
            _aiInsight = cachedInsight;
            _isLoadingAIInsight = false;
          });
        }
      }
    } catch (e) {
      // Cache loading failed, will generate new insights
      print('Failed to load cached insights: $e');
    }
  }

  Future<void> _cacheInsights(String insights) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKeyInsights, insights);
      await prefs.setInt(
        _prefsKeyTimestamp,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      print('Failed to cache insights: $e');
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      _userModel = await _userService.getCurrentUserData();
    } catch (e) {
      print('Failed to load user profile: $e');
    }
  }

  void _processTransactions(List<QueryDocumentSnapshot> docs) {
    if (!mounted) return;

    // Reset financial metrics
    _totalIncome = 0;
    _totalExpenses = 0;
    _categorySpending.clear();

    // Process transactions
    final transactions = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      // Ensure all transactions have a proper date
      if (data['date'] == null) {
        data['date'] = Timestamp.now();
      } else if (data['date'] is String) {
        // Handle string dates - assume ISO 8601 format
        try {
          data['date'] = Timestamp.fromDate(DateTime.parse(data['date']));
        } catch (e) {
          print(
              'Error parsing date string: ${data['date']}, using current time');
          data['date'] = Timestamp.now();
        }
      }
      return data;
    }).toList();

    for (var tx in transactions) {
      final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
      final category = (tx['category'] as String?) ?? 'Uncategorized';

      if (tx['type'] == 'income') {
        _totalIncome += amount;
      } else if (tx['type'] == 'expense') {
        _totalExpenses += amount;
        _categorySpending[category] =
            (_categorySpending[category] ?? 0) + amount;
      }
    }

    if (!mounted) return;
    setState(() {
      _transactions = transactions;
      _netSavings = _totalIncome - _totalExpenses;
    });
  }

  void _generateMonthlyData() {
    if (!mounted) return;

    // Group transactions by month for the spending trend chart
    final Map<String, Map<String, double>> monthlyData = {};

    for (var tx in _transactions) {
      DateTime date;
      if (tx['date'] is Timestamp) {
        date = (tx['date'] as Timestamp).toDate();
      } else if (tx['date'] is String) {
        try {
          date = DateTime.parse(tx['date']);
        } catch (e) {
          print('Error parsing date in _generateMonthlyData: ${tx['date']}');
          continue; // Skip this transaction
        }
      } else {
        print('Unexpected date type: ${tx['date'].runtimeType}');
        continue; // Skip this transaction
      }

      final monthKey = DateFormat('MMM yyyy').format(date);
      final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
      final type = tx['type'] as String? ?? 'expense';

      if (!monthlyData.containsKey(monthKey)) {
        monthlyData[monthKey] = {'income': 0.0, 'expense': 0.0};
      }

      if (type == 'income') {
        monthlyData[monthKey]!['income'] =
            (monthlyData[monthKey]!['income'] ?? 0.0) + amount;
      } else if (type == 'expense') {
        monthlyData[monthKey]!['expense'] =
            (monthlyData[monthKey]!['expense'] ?? 0.0) + amount;
      }
    }

    // Convert to list and sort by date
    final tempData = monthlyData.entries.map((entry) {
      return {
        'month': entry.key,
        'income': entry.value['income'] ?? 0.0,
        'expense': entry.value['expense'] ?? 0.0,
      };
    }).toList();

    // Sort by date (assuming month format is 'MMM yyyy')
    tempData.sort((a, b) {
      final aDate = DateFormat('MMM yyyy').parse(a['month'] as String);
      final bDate = DateFormat('MMM yyyy').parse(b['month'] as String);
      return aDate.compareTo(bDate);
    });

    setState(() {
      _monthlyData = tempData;
    });
  }

  Future<void> _performAIAnalysis() async {
    if (!mounted) return;

    setState(() {
      _isLoadingAIInsight = true;
    });

    try {
      final analysisPrompt = _prepareAnalysisPrompt();
      final response = await _callAIAnalytics(analysisPrompt);

      if (!mounted) return;

      setState(() {
        _aiInsight = response;
        _isLoadingAIInsight = false;
      });

      // Cache the new insights
      _cacheInsights(response);
    } catch (e) {
      print('AI Analysis error: $e');
      if (!mounted) return;

      _showErrorSnackbar('Unable to generate AI insights');
      setState(() {
        _isLoadingAIInsight = false;
        _aiInsight =
            "We couldn't generate AI insights at this time. Please try again later.";
      });
    }
  }

  String _prepareAnalysisPrompt() {
    // Create spending trend description
    String spendingTrend = "No trend data available.";
    if (_monthlyData.length >= 2) {
      final lastMonth = _monthlyData.last;
      final previousMonth = _monthlyData[_monthlyData.length - 2];

      final lastExpense = lastMonth['expense'] as double;
      final prevExpense = previousMonth['expense'] as double;

      final percentChange = prevExpense > 0
          ? ((lastExpense - prevExpense) / prevExpense * 100).toStringAsFixed(1)
          : "N/A";

      spendingTrend =
          "Last month (${lastMonth['month']}): ${_formatCurrency(lastExpense)}. "
          "Compared to previous month (${previousMonth['month']}): ${_formatCurrency(prevExpense)}. "
          "Change: $percentChange%.";
    }

    // Get top spending categories
    final topCategories = _getSortedCategories().take(5).toList();
    String categoryBreakdown = topCategories.isEmpty
        ? "No category data available."
        : topCategories
            .map(
              (entry) =>
                  "${entry.key}: ${_formatCurrency(entry.value)} (${(_getPercentage(entry.value, _totalExpenses)).toStringAsFixed(1)}%)",
            )
            .join(", ");

    // User profile data for personalization
    String userProfileInfo = "";
    if (_userModel != null) {
      final goals = _userModel!.goals.isNotEmpty
          ? _userModel!.goals.join(", ")
          : "No specific goals set";
      final incomeRange = _userModel!.incomeRange ?? "Not specified";
      final riskTolerance = _userModel!.riskTolerance ?? "Not specified";

      userProfileInfo = '''
    - User's Financial Goals: $goals
    - Income Range: $incomeRange
    - Risk Tolerance: $riskTolerance
    ''';
    }

    return '''
    Financial Analysis Prompt:
    - Total Monthly Income: ${_formatCurrency(_totalIncome)}
    - Total Monthly Expenses: ${_formatCurrency(_totalExpenses)}
    - Net Savings: ${_formatCurrency(_netSavings)}
    - Savings Rate: ${_totalIncome > 0 ? (_netSavings / _totalIncome * 100).toStringAsFixed(1) : 0}%
    - Top Spending Categories: $categoryBreakdown
    - Spending Trend: $spendingTrend$userProfileInfo

    As a friendly financial advisor, provide personalized insights about the spending patterns and give 3 specific, practical recommendations to improve financial health. Tailor your advice based on the user's goals, income range, and risk tolerance. Be conversational but concise, and your generated text should be beautiful markdown.
    ''';
  }

  List<MapEntry<String, double>> _getSortedCategories() {
    final sortedEntries = _categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries;
  }

  double _getPercentage(double value, double total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      symbol: 'KSh ',
      decimalDigits: 0,
    ).format(amount);
  }

  Future<String> _callAIAnalytics(String prompt) async {
    return await _aiService.generateFinancialInsights(prompt);
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          left: 20,
          right: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF0F0F1E)
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'FinSpense Analytics',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6C63FF).withOpacity(0.95),
                const Color(0xFF8B85FF).withOpacity(0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: _isFetchingData ? null : _initializeData,
            ),
          ),
        ],
      ),
      body: _buildAnalyticsContent(),
    );
  }

  Widget _buildAnalyticsContent() {
    final user = _auth.currentUser;

    if (user == null) {
      return Center(
        child: Text(
          'Please sign in to continue',
          style: TextStyle(color: const Color(0xFFE91E63)),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            _transactions.isEmpty) {
          return _buildLoadingState();
        }

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _processTransactions(snapshot.data!.docs);
            _generateMonthlyData();

            // Only perform AI analysis once when we first get data and haven't loaded from cache
            if (_isLoadingAIInsight &&
                !_isFetchingData &&
                _aiInsight == 'Analyzing your financial patterns...') {
              _performAIAnalysis();
            }
          });
        } else if (snapshot.hasData &&
            snapshot.data!.docs.isEmpty &&
            _isLoadingAIInsight) {
          // Handle empty transactions case
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _isLoadingAIInsight = false;
              _aiInsight =
                  "No transaction data available. Add transactions to get AI insights.";
            });
          });
        }

        return RefreshIndicator(
          onRefresh: _initializeData,
          color: const Color(0xFFE91E63),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Opacity(
                opacity: _animation.value,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    FinancialSummaryCard(
                      totalIncome: _totalIncome,
                      totalExpenses: _totalExpenses,
                      netSavings: _netSavings,
                      formatCurrency: _formatCurrency,
                      goals: _userModel?.goals ?? [],
                    ),
                    const SizedBox(height: 16),
                    AIInsightCard(
                      aiInsight: _aiInsight,
                      isLoadingAIInsight: _isLoadingAIInsight,
                      performAIAnalysis: _performAIAnalysis,
                    ),
                    const SizedBox(height: 16),
                    CategoryDonutChart(
                      categorySpending: _categorySpending,
                      totalExpenses: _totalExpenses,
                      selectedCategoryIndex: _selectedCategoryIndex,
                      categoryColors: _categoryColors,
                      getPercentage: _getPercentage,
                      formatCurrency: _formatCurrency,
                      onCategorySelected: (index) {
                        setState(() {
                          _selectedCategoryIndex = index;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SpendingTrendCard(monthlyData: _monthlyData),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ],
      ),
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
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFFE91E63),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFE91E63).withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _initializeData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

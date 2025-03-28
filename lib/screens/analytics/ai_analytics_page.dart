import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final String _prefsKeyInsights = 'ai_financial_insights';
  final String _prefsKeyTimestamp = 'ai_insights_timestamp';

  // Financial data variables
  String _aiInsight = 'Analyzing your financial patterns...';
  bool _isLoadingAIInsight = true;
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _monthlyData = [];

  // Financial summaries
  double _totalIncome = 0;
  double _totalExpenses = 0;
  double _netSavings = 0;
  Map<String, double> _categorySpending = {};
  int _selectedCategoryIndex = -1;

  // Animation and UI controllers
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _selectedTimeFrame = 1; // 0: Week, 1: Month, 2: Year
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
    setState(() {
      _isFetchingData = true;
    });

    await _loadCachedInsights();
    await _fetchTransactionsAndAnalyze();

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
          _prefsKeyTimestamp, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Failed to cache insights: $e');
    }
  }

  Future<void> _fetchTransactionsAndAnalyze() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final snapshot = await _firestore
            .collection('transactions')
            .where('userId', isEqualTo: user.uid)
            .orderBy('date', descending: true)
            .get();

        if (snapshot.docs.isEmpty) {
          setState(() {
            _isLoadingAIInsight = false;
            _aiInsight =
                "No transaction data available. Add transactions to get AI insights.";
          });
          return;
        }

        _processTransactions(snapshot.docs);
        _generateMonthlyData();

        // Only perform AI analysis if we haven't already loaded from cache
        if (_isLoadingAIInsight) {
          await _performAIAnalysis();
        }
      } catch (e) {
        _showErrorSnackbar('Failed to fetch financial data');
        setState(() {
          _isLoadingAIInsight = false;
        });
      }
    }
  }

  void _processTransactions(List<QueryDocumentSnapshot> docs) {
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

    setState(() {
      _transactions = transactions;
      _netSavings = _totalIncome - _totalExpenses;
    });
  }

  void _generateMonthlyData() {
    // Group transactions by month for the spending trend chart
    final Map<String, Map<String, double>> monthlyData = {};

    for (var tx in _transactions) {
      final date = (tx['date'] as Timestamp).toDate();
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
    setState(() {
      _isLoadingAIInsight = true;
    });

    try {
      final analysisPrompt = _prepareAnalysisPrompt();
      final response = await _callAIAnalytics(analysisPrompt);

      setState(() {
        _aiInsight = response;
        _isLoadingAIInsight = false;
      });

      // Cache the new insights
      _cacheInsights(response);
    } catch (e) {
      print('AI Analysis error: $e');
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
            .map((entry) =>
                "${entry.key}: ${_formatCurrency(entry.value)} (${(_getPercentage(entry.value, _totalExpenses)).toStringAsFixed(1)}%)")
            .join(", ");

    return '''
    Financial Analysis Prompt:
    - Total Monthly Income: ${_formatCurrency(_totalIncome)}
    - Total Monthly Expenses: ${_formatCurrency(_totalExpenses)}
    - Net Savings: ${_formatCurrency(_netSavings)}
    - Savings Rate: ${_totalIncome > 0 ? (_netSavings / _totalIncome * 100).toStringAsFixed(1) : 0}%
    - Top Spending Categories: $categoryBreakdown
    - Spending Trend: $spendingTrend

    As a friendly financial advisor, provide personalized insights about the spending patterns and give 3 specific, practical recommendations to improve financial health. Be conversational but concise. and your generated text should be a beautiful markdown
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
    return NumberFormat.currency(symbol: 'KSh ', decimalDigits: 0)
        .format(amount);
  }

  Future<String> _callAIAnalytics(String prompt) async {
    const apiUrl = "https://api.together.xyz/v1/chat/completions";
    const apiKey =
        "4db152889da5afebdba262f90e4cdcf12976ee8b48d9135c2bb86ef9b0d12bdd";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: json.encode({
          "model": "meta-llama/Llama-3.3-70B-Instruct-Turbo-Free",
          "messages": [
            {
              "role": "system",
              "content":
                  "You are a friendly financial advisor. Provide helpful, encouraging advice. and do not provide a too long text"
            },
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.7,
          "max_tokens": 300
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else {
        // Enhanced error handling
        print('API Error: ${response.statusCode}');
        print('Response Body: ${response.body}');
        throw Exception('Failed to load AI insights: ${response.statusCode}');
      }
    } catch (e) {
      // Detailed error logging
      print('Exception in _callAIAnalytics: $e');
      throw Exception('Failed to connect to AI service: $e');
    }
  }

  void _showErrorSnackbar(String message) {
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Smart Financial Insights',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF06292), Color(0xFFE91E63)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isFetchingData ? null : _initializeData,
          )
        ],
      ),
      body: _buildAnalyticsContent(),
    );
  }

  Widget _buildAnalyticsContent() {
    return RefreshIndicator(
      onRefresh: _initializeData,
      color: const Color(0xFFE91E63),
      child: _isFetchingData
          ? _buildLoadingState()
          : AnimatedBuilder(
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
                      SpendingTrendCard(
                        monthlyData: _monthlyData,
                      ),
                    ],
                  ),
                );
              }),
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
}

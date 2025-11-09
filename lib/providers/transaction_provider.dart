import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionRepository _transactionRepository = TransactionRepository();

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _summary;

  // Filters
  DateTime? _startDate;
  DateTime? _endDate;
  String? _categoryFilter;
  String? _typeFilter;
  int? _limit;

  // Getters
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get summary => _summary;

  // Filter getters
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String? get categoryFilter => _categoryFilter;
  String? get typeFilter => _typeFilter;

  // Computed properties
  double get totalIncome => _summary?['totalIncome'] ?? 0.0;
  double get totalExpense => _summary?['totalExpense'] ?? 0.0;
  double get netAmount => _summary?['netAmount'] ?? 0.0;
  int get transactionCount => _transactions.length;

  Map<String, double> get categoryIncome =>
      Map<String, double>.from(_summary?['categoryIncome'] ?? {});
  Map<String, double> get categoryExpense =>
      Map<String, double>.from(_summary?['categoryExpense'] ?? {});

  // Get transactions with current filters
  Future<void> loadTransactions(String uid) async {
    _setLoading(true);
    try {
      _transactions = await _transactionRepository.getTransactions(
        uid: uid,
        startDate: _startDate,
        endDate: _endDate,
        category: _categoryFilter,
        type: _typeFilter,
        limit: _limit,
      );

      // Load summary if no filters are applied (full period summary)
      if (_startDate == null &&
          _endDate == null &&
          _categoryFilter == null &&
          _typeFilter == null) {
        await _loadSummary(uid);
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load transactions: $e';
      _transactions = [];
    } finally {
      _setLoading(false);
    }
  }

  // Load transaction summary
  Future<void> _loadSummary(String uid) async {
    try {
      _summary = await _transactionRepository.getTransactionSummary(
        uid: uid,
        startDate: _startDate,
        endDate: _endDate,
      );
    } catch (e) {
      _errorMessage = 'Failed to load summary: $e';
    }
  }

  // Add new transaction
  Future<bool> addTransaction(TransactionModel transaction) async {
    _setLoading(true);
    try {
      final id = await _transactionRepository.addTransaction(transaction);
      final newTransaction = transaction.copyWith(id: id);

      // Add to local list if it matches current filters
      if (_matchesFilters(newTransaction)) {
        _transactions.insert(0, newTransaction);
      }

      // Refresh summary
      await _loadSummary(transaction.uid);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add transaction: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update existing transaction
  Future<bool> updateTransaction(TransactionModel transaction) async {
    if (transaction.id == null) return false;

    _setLoading(true);
    try {
      await _transactionRepository.updateTransaction(
          transaction.id!, transaction, transaction.uid);

      // Update in local list
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
      }

      // Refresh summary
      await _loadSummary(transaction.uid);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update transaction: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete transaction
  Future<bool> deleteTransaction(String transactionId, String uid) async {
    _setLoading(true);
    try {
      await _transactionRepository.deleteTransaction(transactionId, uid);

      // Remove from local list
      _transactions.removeWhere((t) => t.id == transactionId);

      // Refresh summary
      await _loadSummary(uid);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete transaction: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get single transaction
  Future<TransactionModel?> getTransactionById(
      String transactionId, String uid) async {
    try {
      return await _transactionRepository.getTransactionById(
          transactionId, uid);
    } catch (e) {
      _errorMessage = 'Failed to get transaction: $e';
      return null;
    }
  }

  // Get user balance
  Future<double> getUserBalance(String uid) async {
    try {
      return await _transactionRepository.getUserBalance(uid);
    } catch (e) {
      _errorMessage = 'Failed to get balance: $e';
      return 0.0;
    }
  }

  // Get available categories
  Future<List<Map<String, dynamic>>> getCategories({String? type}) async {
    try {
      return await _transactionRepository.getCategories(type: type);
    } catch (e) {
      _errorMessage = 'Failed to get categories: $e';
      return [];
    }
  }

  // Add new category
  Future<bool> addCategory(String name, String type, {String? icon}) async {
    try {
      await _transactionRepository.addCategory(name, type, icon: icon);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add category: $e';
      return false;
    }
  }

  // Filter methods
  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void setTypeFilter(String? type) {
    _typeFilter = type;
    notifyListeners();
  }

  void setLimit(int? limit) {
    _limit = limit;
    notifyListeners();
  }

  void clearFilters() {
    _startDate = null;
    _endDate = null;
    _categoryFilter = null;
    _typeFilter = null;
    _limit = null;
    notifyListeners();
  }

  // Get filtered transactions (client-side filtering for additional logic)
  List<TransactionModel> getFilteredTransactions({
    String? category,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _transactions.where((transaction) {
      if (category != null && transaction.category != category) return false;
      if (type != null && transaction.type != type) return false;
      if (startDate != null && transaction.date.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && transaction.date.isAfter(endDate)) return false;
      return true;
    }).toList();
  }

  // Aggregation methods
  double getTotalByCategory(String category, {String? type}) {
    final filtered = getFilteredTransactions(category: category, type: type);
    return filtered.fold(0.0, (sum, t) => sum + t.amount);
  }

  Map<String, double> getCategoryTotals({String? type}) {
    final Map<String, double> totals = {};
    for (final transaction in _transactions) {
      if (type != null && transaction.type != type) continue;
      totals[transaction.category] =
          (totals[transaction.category] ?? 0) + transaction.amount;
    }
    return totals;
  }

  List<Map<String, dynamic>> getMonthlyTrends(String uid, {int months = 6}) {
    final now = DateTime.now();
    final trends = <Map<String, dynamic>>[];

    for (int i = months - 1; i >= 0; i--) {
      final monthStart = DateTime(now.year, now.month - i, 1);
      final monthEnd = DateTime(now.year, now.month - i + 1, 0);

      final monthTransactions = getFilteredTransactions(
        startDate: monthStart,
        endDate: monthEnd,
      );

      final income = monthTransactions
          .where((t) => t.type == 'income')
          .fold(0.0, (sum, t) => sum + t.amount);

      final expense = monthTransactions
          .where((t) => t.type == 'expense')
          .fold(0.0, (sum, t) => sum + t.amount);

      trends.add({
        'month': monthStart,
        'income': income,
        'expense': expense,
        'net': income - expense,
        'count': monthTransactions.length,
      });
    }

    return trends;
  }

  // Sync transactions
  Future<void> syncTransactions(String uid) async {
    _setLoading(true);
    try {
      await _transactionRepository.syncTransactions(uid);
      // Reload transactions after sync
      await loadTransactions(uid);
    } catch (e) {
      _errorMessage = 'Failed to sync transactions: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Utility methods
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  bool _matchesFilters(TransactionModel transaction) {
    if (_startDate != null && transaction.date.isBefore(_startDate!)) {
      return false;
    }
    if (_endDate != null && transaction.date.isAfter(_endDate!)) return false;
    if (_categoryFilter != null && transaction.category != _categoryFilter) {
      return false;
    }
    if (_typeFilter != null && transaction.type != _typeFilter) return false;
    return true;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

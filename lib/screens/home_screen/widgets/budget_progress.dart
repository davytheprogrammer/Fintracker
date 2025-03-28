import 'package:flutter/material.dart';

// Enhanced constants with better organization
class BudgetConstants {
  static const double defaultPadding = 16.0;
  static const double progressBarHeight = 8.0;
  static const double dangerThreshold = 0.9; // Changed from warning
  static const double warningThreshold = 0.75; // More granular thresholds
  static const double cautionThreshold = 0.6;

  // Gradient colors for background
  static const Color gradientStart = Color(0xFFFCE4EC); // Light pink
  static const Color gradientEnd = Color(0xFFF8BBD0); // Slightly darker pink

  // Budget status colors
  static const Color safeColor = Color(0xFF4CAF50); // Material Green
  static const Color cautionColor = Color(0xFFFFA726); // Material Orange
  static const Color warningColor = Color(0xFFEF6C00); // Deeper Orange
  static const Color dangerColor = Color(0xFFD32F2F); // Material Red
}

enum BudgetHealthStatus {
  excellent,
  good,
  caution,
  danger;

  String get displayMessage {
    switch (this) {
      case BudgetHealthStatus.excellent:
        return 'Excellent Budget Control';
      case BudgetHealthStatus.good:
        return 'Good Budget Management';
      case BudgetHealthStatus.caution:
        return 'Approaching Budget Limits';
      case BudgetHealthStatus.danger:
        return 'Over Budget - Action Needed';
    }
  }

  Color get statusColor {
    switch (this) {
      case BudgetHealthStatus.excellent:
        return BudgetConstants.safeColor;
      case BudgetHealthStatus.good:
        return BudgetConstants.safeColor.withOpacity(0.8);
      case BudgetHealthStatus.caution:
        return BudgetConstants.cautionColor;
      case BudgetHealthStatus.danger:
        return BudgetConstants.dangerColor;
    }
  }
}

enum BudgetCategory {
  essentials, // Changed from bills - more descriptive
  savings,
  discretionary, // Changed from shopping - more accurate
  leisure; // Changed from entertainment - more professional

  String get displayName => name[0].toUpperCase() + name.substring(1);

  // Enhanced allocation logic with proper financial planning principles
  double get allocationPercentage {
    switch (this) {
      case BudgetCategory.essentials:
        return 0.5; // 50% for essentials (rent, utilities, food)
      case BudgetCategory.savings:
        return 0.2; // 20% for savings (emergency fund, investments)
      case BudgetCategory.discretionary:
        return 0.2; // 20% for discretionary (shopping, personal care)
      case BudgetCategory.leisure:
        return 0.1; // 10% for leisure (entertainment, dining out)
    }
  }
}

class BudgetProgress extends StatelessWidget {
  final double? totalIncome;
  final double? totalExpenses;
  final String Function(double) formatCurrency;

  const BudgetProgress({
    Key? key,
    this.totalIncome,
    this.totalExpenses,
    required this.formatCurrency,
  }) : super(key: key);

  // Enhanced budget health calculation
  BudgetHealthStatus _calculateBudgetHealth(double income, double expenses) {
    if (income <= 0) return BudgetHealthStatus.danger;

    final spendingRatio = expenses / income;

    if (spendingRatio >= BudgetConstants.dangerThreshold) {
      return BudgetHealthStatus.danger;
    } else if (spendingRatio >= BudgetConstants.warningThreshold) {
      return BudgetHealthStatus.caution;
    } else if (spendingRatio >= BudgetConstants.cautionThreshold) {
      return BudgetHealthStatus.good;
    } else {
      return BudgetHealthStatus.excellent;
    }
  }

  // Enhanced progress color logic - NOW with proper financial indication
  Color _getProgressColor(double progress) {
    if (progress >= BudgetConstants.dangerThreshold) {
      return BudgetConstants.dangerColor;
    } else if (progress >= BudgetConstants.warningThreshold) {
      return BudgetConstants.warningColor;
    } else if (progress >= BudgetConstants.cautionThreshold) {
      return BudgetConstants.cautionColor;
    }
    return BudgetConstants.safeColor;
  }

  @override
  Widget build(BuildContext context) {
    final double safeIncome = totalIncome ?? 0;
    final double safeExpenses = totalExpenses ?? 0;
    final budgetHealth = _calculateBudgetHealth(safeIncome, safeExpenses);

    return Container(
      margin: const EdgeInsets.all(BudgetConstants.defaultPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            BudgetConstants.gradientStart,
            BudgetConstants.gradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _BudgetHeader(
            totalIncome: safeIncome,
            budgetHealth: budgetHealth,
          ),
          _BudgetSummary(
            income: safeIncome,
            expenses: safeExpenses,
            formatCurrency: formatCurrency,
          ),
          if (safeIncome > 0) ...[
            const Divider(height: 32),
            Padding(
              padding: const EdgeInsets.all(BudgetConstants.defaultPadding),
              child: _buildCategoryBars(safeIncome, safeExpenses),
            ),
          ] else
            const _EmptyStateWidget(),
        ],
      ),
    );
  }

  Widget _buildCategoryBars(double income, double expenses) {
    return Column(
      children: BudgetCategory.values.map((category) {
        final allocated = income * category.allocationPercentage;
        final spent = expenses * category.allocationPercentage;
        final progress = (spent / allocated).clamp(0.0, 1.0);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _BudgetProgressBar(
            category: category,
            spent: spent,
            allocated: allocated,
            progress: progress,
            formatCurrency: formatCurrency,
          ),
        );
      }).toList(),
    );
  }
}

class _BudgetHeader extends StatelessWidget {
  final double totalIncome;
  final BudgetHealthStatus budgetHealth;

  const _BudgetHeader({
    required this.totalIncome,
    required this.budgetHealth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BudgetConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Budget Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (totalIncome > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: budgetHealth.statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                budgetHealth.displayMessage,
                style: TextStyle(
                  color: budgetHealth.statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BudgetSummary extends StatelessWidget {
  final double income;
  final double expenses;
  final String Function(double) formatCurrency;

  const _BudgetSummary({
    required this.income,
    required this.expenses,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(BudgetConstants.defaultPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
            label: 'Income',
            amount: formatCurrency(income),
            color: BudgetConstants.safeColor,
          ),
          _SummaryItem(
            label: 'Expenses',
            amount: formatCurrency(expenses),
            color: expenses > income
                ? BudgetConstants.dangerColor
                : BudgetConstants.cautionColor,
          ),
          _SummaryItem(
            label: 'Remaining',
            amount:
                formatCurrency((income - expenses).clamp(0, double.infinity)),
            color: income > expenses
                ? BudgetConstants.safeColor
                : BudgetConstants.dangerColor,
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// Enhanced progress bar with better visual feedback
class _BudgetProgressBar extends StatelessWidget {
  final BudgetCategory category;
  final double spent;
  final double allocated;
  final double progress;
  final String Function(double) formatCurrency;

  const _BudgetProgressBar({
    required this.category,
    required this.spent,
    required this.allocated,
    required this.progress,
    required this.formatCurrency,
  });

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return BudgetConstants.dangerColor;
    if (progress >= 0.9) return BudgetConstants.warningColor;
    if (progress >= 0.75) return BudgetConstants.cautionColor;
    return BudgetConstants.safeColor;
  }

  @override
  Widget build(BuildContext context) {
    final Color progressColor = _getProgressColor(progress);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category.displayName,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            Text(
              '${formatCurrency(spent)} / ${formatCurrency(allocated)}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: progressColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: BudgetConstants.progressBarHeight,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: BudgetConstants.progressBarHeight,
              width: double.infinity * progress.clamp(0.0, 1.0),
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 12,
            color: progressColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  const _EmptyStateWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BudgetConstants.defaultPadding * 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Ready to Start Budgeting?',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your income to see a detailed breakdown\nof recommended budget allocations',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

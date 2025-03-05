import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    // Handle null values with default of 0
    final double safeIncome = totalIncome ?? 0;
    final double safeExpenses = totalExpenses ?? 0;

    final Map<String, double> budgetCategories = {
      'Shopping': safeExpenses * 0.4,
      'Bills': safeExpenses * 0.3,
      'Entertainment': safeExpenses * 0.2,
      'Savings': safeIncome - safeExpenses,
    };

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Budget Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          if (safeIncome == 0)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Waiting for budget data...',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...budgetCategories.entries.map(
                  (e) => buildBudgetProgressBar(context, e.key, e.value, safeIncome),
            ),
        ],
      ),
    );
  }

  Widget buildBudgetProgressBar(
      BuildContext context,
      String category,
      double amount,
      double total,
      ) {
    // Ensure progress is between 0 and 1
    final double progress = total > 0 ? (amount / total).clamp(0.0, 1.0) : 0.0;

    final Color color = progress > 0.7
        ? Colors.red
        : progress > 0.4
        ? Colors.orange
        : Colors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              formatCurrency(amount),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  height: 8,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  height: 8,
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
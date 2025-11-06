import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpenseChart extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;
  final String Function(double) formatCurrency;

  ExpenseChart({required this.transactions, required this.formatCurrency});

  @override
  _ExpenseChartState createState() => _ExpenseChartState();
}

class _ExpenseChartState extends State<ExpenseChart>
    with SingleTickerProviderStateMixin {
  int touchedIndex = -1;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Process transactions to get category-based expenses
    Map<String, double> categoryExpenses = {};
    double totalExpense = 0;

    for (var tx in widget.transactions) {
      if (tx['type'] == 'expense') {
        String category = tx['category'] ?? 'Other';
        double amount = tx['amount'];
        categoryExpenses[category] = (categoryExpenses[category] ?? 0) + amount;
        totalExpense += amount;
      }
    }

    // Define muted pastel colors similar to the example image
    final Map<String, Color> categoryColors = {
      'Shopping': Color(0xFF673AB7),
      'Health': Color(0xFF9C27B0),
      'Invest': Color(0xFFB39DDB),
      'Tax': Color(0xFFD1C4E9),
      'Charity': Color(0xFFE1BEE7),
      'Food': Color(0xFF3F51B5),
      'Transport': Color(0xFF2196F3),
      'Rent': Color(0xFF4CAF50),
      'Utilities': Color(0xFF8BC34A),
      'Entertainment': Color(0xFFFFC107),
      'Other': Color(0xFF9E9E9E),
    };

    // Sort categories by expense amount (descending)
    List<MapEntry<String, double>> sortedCategories =
        categoryExpenses.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    // Create pie chart sections
    List<PieChartSectionData> sections = [];

    for (var entry in sortedCategories) {
      final String category = entry.key;
      final double amount = entry.value;
      final double percentage = totalExpense > 0
          ? (amount / totalExpense) * 100
          : 0;

      final Color color = categoryColors[category] ?? Color(0xFF9E9E9E);

      final isTouched = sortedCategories.indexOf(entry) == touchedIndex;
      final double radius = isTouched ? 25 : 20; // Thin donut

      sections.add(
        PieChartSectionData(
          color: color,
          value: amount,
          title: '', // No text on the chart segments
          radius: radius,
          titleStyle: TextStyle(
            fontSize: 0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expenses',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'View Analytics',
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Opacity(
                opacity: _animation.value,
                child: Container(
                  height: 200,
                  child: sections.isEmpty
                      ? Center(
                          child: Text(
                            'No expense data available',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                  touchCallback:
                                      (FlTouchEvent event, pieTouchResponse) {
                                        setState(() {
                                          if (!event
                                                  .isInterestedForInteractions ||
                                              pieTouchResponse == null ||
                                              pieTouchResponse.touchedSection ==
                                                  null) {
                                            touchedIndex = -1;
                                            return;
                                          }
                                          touchedIndex = pieTouchResponse
                                              .touchedSection!
                                              .touchedSectionIndex;
                                        });
                                      },
                                ),
                                borderData: FlBorderData(show: false),
                                sectionsSpace: 0, // No gaps between sections
                                centerSpaceRadius: 70, // Large center hole
                                sections: sections.map((section) {
                                  return PieChartSectionData(
                                    color: section.color,
                                    value: section.value,
                                    title: section.title,
                                    radius: section.radius * _animation.value,
                                    titleStyle: section.titleStyle,
                                  );
                                }).toList(),
                              ),
                            ),
                            // Centered total text
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Monthly Expenses',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 11,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  widget.formatCurrency(totalExpense),
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              );
            },
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: sortedCategories.take(5).map((entry) {
              final String category = entry.key;
              final double amount = entry.value;
              final Color color = categoryColors[category] ?? Color(0xFF9E9E9E);

              return Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    category,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    widget.formatCurrency(amount),
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

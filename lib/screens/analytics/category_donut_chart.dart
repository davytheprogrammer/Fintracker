import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CategoryDonutChart extends StatelessWidget {
  final Map<String, double> categorySpending;
  final double totalExpenses;
  final int selectedCategoryIndex;
  final List<Color> categoryColors;
  final double Function(double, double) getPercentage;
  final String Function(double) formatCurrency;
  final Function(int) onCategorySelected;

  const CategoryDonutChart({
    Key? key,
    required this.categorySpending,
    required this.totalExpenses,
    required this.selectedCategoryIndex,
    required this.categoryColors,
    required this.getPercentage,
    required this.formatCurrency,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortedCategories = _getSortedCategories();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending by Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.pink[800],
              ),
            ),
            const SizedBox(height: 20),
            sortedCategories.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'No expense data available',
                        style: TextStyle(color: Colors.pink[300]),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      SizedBox(
                        height: 220,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildPieChart(sortedCategories),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 2,
                              child: _buildCategoryLegend(sortedCategories),
                            ),
                          ],
                        ),
                      ),
                      if (selectedCategoryIndex != -1 &&
                          selectedCategoryIndex < sortedCategories.length)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: _buildCategoryDetails(
                            sortedCategories[selectedCategoryIndex],
                          ),
                        ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  List<MapEntry<String, double>> _getSortedCategories() {
    final sortedEntries = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries;
  }

  Widget _buildPieChart(List<MapEntry<String, double>> categories) {
    return AspectRatio(
      aspectRatio: 1,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                onCategorySelected(-1);
                return;
              }
              onCategorySelected(
                pieTouchResponse.touchedSection!.touchedSectionIndex,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          sectionsSpace: 2,
          centerSpaceRadius: 60,
          sections: _generatePieChartSections(categories),
          startDegreeOffset: -90,
        ),
        swapAnimationDuration: const Duration(milliseconds: 500),
        swapAnimationCurve: Curves.easeInOutCubic,
      ),
    );
  }

  List<PieChartSectionData> _generatePieChartSections(
    List<MapEntry<String, double>> categories,
  ) {
    return categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value.key;
      final value = entry.value.value;
      final percentage = getPercentage(value, totalExpenses);

      final isTouched = index == selectedCategoryIndex;
      final radius = isTouched ? 30.0 : 25.0;

      return PieChartSectionData(
        color: categoryColors[index % categoryColors.length],
        value: value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: isTouched ? 16 : 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titlePositionPercentageOffset: 0.6,
      );
    }).toList();
  }

  Widget _buildCategoryLegend(List<MapEntry<String, double>> categories) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: categories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value.key;
          final value = entry.value.value;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: InkWell(
              onTap: () {
                onCategorySelected(selectedCategoryIndex == index ? -1 : index);
              },
              borderRadius: BorderRadius.circular(4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: categoryColors[index % categoryColors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      category,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.pink[700],
                        fontWeight: selectedCategoryIndex == index
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  Text(
                    '${getPercentage(value, totalExpenses).toStringAsFixed(0)}%',
                    style: TextStyle(fontSize: 12, color: Colors.pink[600]),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryDetails(MapEntry<String, double> category) {
    final percentage = getPercentage(category.value, totalExpenses);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.pink[100]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.key,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.pink[700],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount: ${formatCurrency(category.value)}',
                style: TextStyle(fontSize: 14, color: Colors.pink[600]),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}% of total expenses',
                style: TextStyle(fontSize: 14, color: Colors.pink[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class SpendingTrendCard extends StatelessWidget {
  final List<Map<String, dynamic>> monthlyData;

  const SpendingTrendCard({
    Key? key,
    required this.monthlyData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Spending Trend',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.pink[800],
              ),
            ),
            const SizedBox(height: 24),
            monthlyData.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'No spending trend data available',
                        style: TextStyle(color: Colors.pink[300]),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 300,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.pink[50]!,
                              strokeWidth: 1,
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(
                              color: Colors.pink[50]!,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: Text(
                                    NumberFormat.compact().format(value),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.pink[600],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value < 0 || value >= monthlyData.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    monthlyData[value.toInt()]['month']
                                        .toString()
                                        .substring(0, 3),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.pink[600],
                                    ),
                                  ),
                                );
                              },
                              reservedSize: 30,
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: Colors.pink[100]!,
                            width: 1,
                          ),
                        ),
                        minX: 0,
                        maxX: (monthlyData.length - 1).toDouble(),
                        minY: 0,
                        maxY: monthlyData.fold(
                                0.0,
                                (max, item) => math.max(
                                    max,
                                    math.max(item['income'] as double,
                                        item['expense'] as double))) *
                            1.2,
                        lineBarsData: [
                          _buildLineChartBarData(true), // Income line
                          _buildLineChartBarData(false), // Expense line
                        ],
                      ),
                    ),
                  ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Income', Colors.pink[400]!),
                const SizedBox(width: 20),
                _buildLegendItem('Expenses', Colors.pink[600]!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _buildLineChartBarData(bool isIncome) {
    return LineChartBarData(
      spots: monthlyData.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(),
            entry.value[isIncome ? 'income' : 'expense'] as double);
      }).toList(),
      isCurved: true,
      color: isIncome ? Colors.pink[400]! : Colors.pink[600]!,
      gradient: isIncome
          ? LinearGradient(
              colors: [Colors.pink[300]!, Colors.pink[400]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )
          : LinearGradient(
              colors: [Colors.pink[600]!, Colors.pink[700]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: isIncome ? Colors.pink[400]! : Colors.pink[600]!,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            isIncome ? Colors.pink[300]! : Colors.pink[600]!,
            Colors.white
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.1, 1.0],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

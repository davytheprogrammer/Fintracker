import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class SpendingTrendCard extends StatelessWidget {
  final List<Map<String, dynamic>> monthlyData;

  const SpendingTrendCard({Key? key, required this.monthlyData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withOpacity(0.1),
            const Color(0xFF8B5CF6).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1).withOpacity(0.2),
                        const Color(0xFF8B5CF6).withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: Color(0xFF6366F1),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Monthly Spending Trend',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6366F1).withOpacity(0.3),
                    Colors.transparent,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            const SizedBox(height: 20),
            monthlyData.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            size: 48,
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No spending trend data available',
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFFB8B9BE)
                                  : const Color(0xFF6B7280),
                              fontSize: 16,
                            ),
                          ),
                        ],
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
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              strokeWidth: 1,
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    NumberFormat.compact().format(value),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: const Color(0xFF6366F1)
                                          .withOpacity(0.7),
                                      fontWeight: FontWeight.w500,
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
                                      fontSize: 11,
                                      color: const Color(0xFF6366F1)
                                          .withOpacity(0.7),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              },
                              reservedSize: 30,
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: const Color(0xFF6366F1).withOpacity(0.2),
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
                                math.max(
                                  item['income'] as double,
                                  item['expense'] as double,
                                ),
                              ),
                            ) *
                            1.2,
                        lineBarsData: [
                          _buildLineChartBarData(true), // Income line
                          _buildLineChartBarData(false), // Expense line
                        ],
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Income', const Color(0xFF10B981)),
                const SizedBox(width: 16),
                _buildLegendItem('Expenses', const Color(0xFFEF4444)),
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
        return FlSpot(
          entry.key.toDouble(),
          entry.value[isIncome ? 'income' : 'expense'] as double,
        );
      }).toList(),
      isCurved: true,
      color: isIncome ? Colors.green : Colors.red,
      gradient: isIncome
          ? LinearGradient(
              colors: [Colors.green[300]!, Colors.green[400]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )
          : LinearGradient(
              colors: [Colors.red[600]!, Colors.red[700]!],
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
            color: isIncome ? Colors.green : Colors.red,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            isIncome
                ? Colors.green.withOpacity(0.3)
                : Colors.red.withOpacity(0.3),
            Colors.white,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

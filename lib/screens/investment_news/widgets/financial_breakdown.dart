import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/constants.dart';

class FinancialBreakdown extends StatelessWidget {
  final Map<String, dynamic> roadmapData;
  final String currencySymbol;
  final String userBudget;

  const FinancialBreakdown({
    super.key,
    required this.roadmapData,
    this.currencySymbol = 'KES',
    this.userBudget = '0',
  });

  @override
  Widget build(BuildContext context) {
    final financials = roadmapData['financial_projection'];
    final yearlyGrowth = (financials['yearly_growth'] as List);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: glassCardDecoration(isDark: isDarkMode),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_money, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Financial Projection',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const Divider(color: AppColors.divider),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: isDarkMode ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Budget',
                          style: AppTypography.labelMedium.copyWith(
                            color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '$currencySymbol $userBudget',
                          style: AppTypography.headlineSmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 40, color: AppColors.divider),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expected Revenue',
                          style: AppTypography.labelMedium.copyWith(
                            color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '$currencySymbol ${financials['expected_revenue']}',
                          style: AppTypography.headlineSmall.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Yearly Growth Projection',
              style: AppTypography.titleMedium.copyWith(
                color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              height: 200,
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: yearlyGrowth.isNotEmpty
                  ? BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: yearlyGrowth.cast<num>().fold<double>(
                                  0,
                                  (p, c) => (p > c.toDouble() ? p : c.toDouble()),
                                ) *
                            1.2,
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}%',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: isDarkMode ? AppColors.textTertiaryDark : AppColors.textTertiary,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Year ${value.toInt() + 1}',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: isDarkMode ? AppColors.textTertiaryDark : AppColors.textTertiary,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: yearlyGrowth
                            .asMap()
                            .entries
                            .map(
                              (entry) => BarChartGroupData(
                                x: entry.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.value.toDouble(),
                                    gradient: LinearGradient(
                                      colors: AppColors.primaryGradient,
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                    width: 16,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(AppRadius.xs),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    )
                  : Center(
                      child: Text(
                        'No growth data available',
                        style: AppTypography.bodyMedium.copyWith(
                          fontStyle: FontStyle.italic,
                          color: isDarkMode ? AppColors.textTertiaryDark : AppColors.textTertiary,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

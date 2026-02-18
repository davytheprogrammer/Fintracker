import 'package:flutter/material.dart';
import '../../../shared/constants.dart';

class RiskAssessment extends StatelessWidget {
  final Map<String, dynamic> roadmapData;

  const RiskAssessment({super.key, required this.roadmapData});

  @override
  Widget build(BuildContext context) {
    final riskAssessment = roadmapData['risk_assessment'];
    final riskScore = riskAssessment['score'];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Color getRiskColor(String score) {
      switch (score.toLowerCase()) {
        case 'low':
          return AppColors.success;
        case 'medium':
          return AppColors.warning;
        case 'high':
          return AppColors.error;
        default:
          return AppColors.textTertiary;
      }
    }

    IconData getRiskIcon(String score) {
      switch (score.toLowerCase()) {
        case 'low':
          return Icons.check_circle;
        case 'medium':
          return Icons.warning;
        case 'high':
          return Icons.error;
        default:
          return Icons.help;
      }
    }

    final riskColor = getRiskColor(riskScore);

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
                const Icon(Icons.security, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Risk Assessment',
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
                color: riskColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: riskColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    getRiskIcon(riskScore),
                    color: riskColor,
                    size: 32,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Risk Level',
                        style: AppTypography.labelMedium.copyWith(
                          color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        riskScore.toUpperCase(),
                        style: AppTypography.headlineSmall.copyWith(
                          color: riskColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Identified Risks',
              style: AppTypography.titleMedium.copyWith(
                color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: (riskAssessment['risks'] as List).length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.xs),
              itemBuilder: (context, index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        riskAssessment['risks'][index],
                        style: AppTypography.bodyMedium.copyWith(
                          color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Mitigation Strategies',
              style: AppTypography.titleMedium.copyWith(
                color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: (riskAssessment['mitigation'] as List).length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.xs),
              itemBuilder: (context, index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        riskAssessment['mitigation'][index],
                        style: AppTypography.bodyMedium.copyWith(
                          color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

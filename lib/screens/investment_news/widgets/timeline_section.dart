import 'package:flutter/material.dart';
import '../../../shared/constants.dart';

class TimelineSection extends StatelessWidget {
  final Map<String, dynamic> roadmapData;

  const TimelineSection({super.key, required this.roadmapData});

  @override
  Widget build(BuildContext context) {
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
                const Icon(Icons.timeline, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Investment Timeline',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const Divider(color: AppColors.divider),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: (roadmapData['investment_timeline'] as List).length,
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Container(
                  height: 20,
                  width: 2,
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              itemBuilder: (context, index) {
                final phase = roadmapData['investment_timeline'][index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: AppColors.primaryGradient),
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.small,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: AppTypography.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: isDarkMode ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: isDarkMode ? AppColors.borderDark : AppColors.border,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${phase['phase']}',
                              style: AppTypography.titleMedium.copyWith(
                                color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '${phase['start']} - ${phase['end']}',
                              style: AppTypography.bodySmall.copyWith(
                                color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                            ),
                          ],
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

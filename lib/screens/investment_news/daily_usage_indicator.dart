import 'package:flutter/material.dart';
import '../../shared/constants.dart';

class DailyUsageIndicator extends StatelessWidget {
  final int dailyUsageCount;
  final int maxDailyRoadmaps;
  final bool isDarkMode;
  final ThemeData theme;

  const DailyUsageIndicator({
    super.key, 
    required this.dailyUsageCount,
    required this.maxDailyRoadmaps,
    required this.isDarkMode,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceVariantDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: isDarkMode ? AppShadows.medium : AppShadows.small,
        border: Border.all(
          color: isDarkMode ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Daily Roadmaps Generated:',
            style: AppTypography.labelLarge.copyWith(
              color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: List.generate(
              maxDailyRoadmaps,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < dailyUsageCount
                      ? AppColors.primary
                      : isDarkMode
                          ? AppColors.surfaceDark
                          : AppColors.background,
                  border: Border.all(
                    color: index < dailyUsageCount
                        ? AppColors.primary
                        : isDarkMode
                            ? AppColors.borderDark
                            : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: index < dailyUsageCount
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

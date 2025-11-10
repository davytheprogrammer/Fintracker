import 'package:flutter/material.dart';
import '../../../models/gamification/streak_model.dart';
import '../../../shared/constants.dart';

class StreakCard extends StatelessWidget {
  final StreakModel streak;
  final VoidCallback? onTap;

  const StreakCard({
    Key? key,
    required this.streak,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
          boxShadow: AppShadows.small,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getStreakColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                Icons.local_fire_department,
                color: _getStreakColor(),
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    streak.name,
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${streak.currentCount} day${streak.currentCount != 1 ? 's' : ''} • Best: ${streak.longestCount}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: _getStreakColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                streak.currentCount.toString(),
                style: AppTypography.labelMedium.copyWith(
                  color: _getStreakColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStreakColor() {
    if (streak.currentCount >= 30) {
      return AppColors.error; // Legendary streak
    } else if (streak.currentCount >= 14) {
      return AppColors.warning; // Epic streak
    } else if (streak.currentCount >= 7) {
      return AppColors.accent; // Rare streak
    } else if (streak.currentCount >= 3) {
      return AppColors.primary; // Uncommon streak
    } else {
      return AppColors.success; // Common streak
    }
  }
}

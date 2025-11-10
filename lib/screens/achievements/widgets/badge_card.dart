import 'package:flutter/material.dart';
import '../../../models/gamification/badge_model.dart';
import '../../../shared/constants.dart';

class BadgeCard extends StatelessWidget {
  final BadgeModel badge;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const BadgeCard({
    Key? key,
    required this.badge,
    this.isUnlocked = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isUnlocked
              ? AppColors.surface
              : AppColors.surfaceDark.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isUnlocked
                ? _getRarityColor(badge.rarity)
                : AppColors.borderDark,
            width: isUnlocked ? 2 : 1,
          ),
          boxShadow: isUnlocked ? AppShadows.small : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUnlocked ? Icons.emoji_events : Icons.lock,
              color: isUnlocked
                  ? _getRarityColor(badge.rarity)
                  : AppColors.textTertiaryDark,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              badge.name,
              style: AppTypography.labelSmall.copyWith(
                color: isUnlocked
                    ? AppColors.textPrimary
                    : AppColors.textTertiaryDark,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _getRarityColor(BadgeRarity rarity) {
    switch (rarity) {
      case BadgeRarity.common:
        return AppColors.success;
      case BadgeRarity.uncommon:
        return AppColors.primary;
      case BadgeRarity.rare:
        return AppColors.accent;
      case BadgeRarity.epic:
        return AppColors.warning;
      case BadgeRarity.legendary:
        return AppColors.error;
    }
  }
}

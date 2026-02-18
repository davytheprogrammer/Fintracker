import 'package:flutter/material.dart';
import '../../shared/constants.dart';

class ErrorMessage extends StatelessWidget {
  final String message;

  const ErrorMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.error.withOpacity(0.1) : AppColors.errorLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: isDarkMode ? AppColors.error : AppColors.errorLight,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: isDarkMode ? AppColors.errorLight : AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

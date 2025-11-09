import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Finspense/shared/constants.dart';
import 'onboarding_provider.dart';

class IncomeSelectScreen extends StatelessWidget {
  const IncomeSelectScreen({Key? key}) : super(key: key);

  static const List<String> _incomeRanges = [
    'Under 500',
    '500 - 1,000',
    '1,000 - 2,500',
    '2,500 - 5,000',
    '5,000 - 10,000',
    'Over 10,000',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        final currencySymbol = provider.selectedCurrency?.symbol ?? '\$';

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxl),

              // Title
              Text(
                'What\'s your monthly income?',
                style: AppTypography.headlineMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Subtitle
              Text(
                'This helps us provide personalized recommendations',
                style: AppTypography.bodyLarge.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.7),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // Income Ranges
              Expanded(
                child: ListView.builder(
                  itemCount: _incomeRanges.length,
                  itemBuilder: (context, index) {
                    final range = _incomeRanges[index];
                    final isSelected = provider.incomeRange == range;

                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.3)
                              : Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: RadioListTile<String>(
                        value: range,
                        groupValue: provider.incomeRange,
                        onChanged: (String? value) {
                          if (value != null) {
                            provider.setIncomeRange(value);
                          }
                        },
                        title: Text(
                          '$currencySymbol $range',
                          style: AppTypography.bodyLarge.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          _getRangeDescription(range),
                          style: AppTypography.bodySmall.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                        ),
                        secondary: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.1)
                                : Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Icon(
                            _getRangeIcon(range),
                            color: isSelected
                                ? AppColors.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.5),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Selected Income Display
              if (provider.incomeRange != null)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Selected: $currencySymbol ${provider.incomeRange}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _getRangeDescription(String range) {
    switch (range) {
      case 'Under 500':
        return 'Entry-level or minimal income';
      case '500 - 1,000':
        return 'Lower middle income range';
      case '1,000 - 2,500':
        return 'Middle income range';
      case '2,500 - 5,000':
        return 'Upper middle income range';
      case '5,000 - 10,000':
        return 'High income range';
      case 'Over 10,000':
        return 'Very high income range';
      default:
        return '';
    }
  }

  IconData _getRangeIcon(String range) {
    switch (range) {
      case 'Under 500':
        return Icons.trending_down;
      case '500 - 1,000':
        return Icons.trending_flat;
      case '1,000 - 2,500':
        return Icons.trending_up;
      case '2,500 - 5,000':
        return Icons.show_chart;
      case '5,000 - 10,000':
        return Icons.bar_chart;
      case 'Over 10,000':
        return Icons.stacked_line_chart;
      default:
        return Icons.attach_money;
    }
  }
}

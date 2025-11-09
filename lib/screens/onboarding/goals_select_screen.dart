import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Finspense/shared/constants.dart';
import 'onboarding_provider.dart';

class GoalsSelectScreen extends StatelessWidget {
  const GoalsSelectScreen({Key? key}) : super(key: key);

  static const List<String> _availableGoals = [
    'Emergency Fund',
    'Home Purchase',
    'Retirement',
    'Debt Payoff',
    'Investment',
    'Travel',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxl),

              // Title
              Text(
                'What are your financial goals?',
                style: AppTypography.headlineMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Subtitle
              Text(
                'Select all that apply. You can change these later.',
                style: AppTypography.bodyLarge.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.7),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // Goals List
              Expanded(
                child: ListView.builder(
                  itemCount: _availableGoals.length,
                  itemBuilder: (context, index) {
                    final goal = _availableGoals[index];
                    final isSelected = provider.selectedGoals.contains(goal);

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
                      child: CheckboxListTile(
                        value: isSelected,
                        onChanged: (bool? value) {
                          final newGoals =
                              List<String>.from(provider.selectedGoals);
                          if (value == true) {
                            newGoals.add(goal);
                          } else {
                            newGoals.remove(goal);
                          }
                          provider.setGoals(newGoals);
                        },
                        title: Text(
                          goal,
                          style: AppTypography.bodyLarge.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          _getGoalDescription(goal),
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
                            _getGoalIcon(goal),
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

              // Selected Goals Summary
              if (provider.selectedGoals.isNotEmpty)
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Goals (${provider.selectedGoals.length})',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: provider.selectedGoals.map((goal) {
                          return Chip(
                            label: Text(
                              goal,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            side: BorderSide(
                              color: AppColors.primary.withOpacity(0.3),
                              width: 1,
                            ),
                          );
                        }).toList(),
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

  String _getGoalDescription(String goal) {
    switch (goal) {
      case 'Emergency Fund':
        return 'Build a safety net for unexpected expenses';
      case 'Home Purchase':
        return 'Save for your dream home or property';
      case 'Retirement':
        return 'Plan for a comfortable retirement life';
      case 'Debt Payoff':
        return 'Eliminate credit card or loan debts';
      case 'Investment':
        return 'Grow your wealth through investments';
      case 'Travel':
        return 'Save for vacations and travel experiences';
      default:
        return '';
    }
  }

  IconData _getGoalIcon(String goal) {
    switch (goal) {
      case 'Emergency Fund':
        return Icons.security;
      case 'Home Purchase':
        return Icons.home;
      case 'Retirement':
        return Icons.accessibility_new;
      case 'Debt Payoff':
        return Icons.credit_card_off;
      case 'Investment':
        return Icons.trending_up;
      case 'Travel':
        return Icons.flight;
      default:
        return Icons.flag;
    }
  }
}

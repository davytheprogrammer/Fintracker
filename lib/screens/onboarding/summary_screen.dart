import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Finspense/shared/constants.dart';
import 'onboarding_provider.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({Key? key}) : super(key: key);

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
                'Review Your Setup',
                style: AppTypography.headlineMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Subtitle
              Text(
                'Please review your selections. You can go back to edit any section.',
                style: AppTypography.bodyLarge.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.7),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // Summary Cards
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Currency
                      _buildSummaryCard(
                        context,
                        title: 'Currency',
                        value: provider.selectedCurrency != null
                            ? '${provider.selectedCurrency!.symbol} ${provider.selectedCurrency!.code}'
                            : 'Not selected',
                        icon: Icons.currency_exchange,
                        onEdit: () => _jumpToPage(context, 1),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Goals
                      _buildSummaryCard(
                        context,
                        title: 'Financial Goals',
                        value: provider.selectedGoals.isNotEmpty
                            ? provider.selectedGoals.join(', ')
                            : 'No goals selected',
                        icon: Icons.flag,
                        onEdit: () => _jumpToPage(context, 2),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Income
                      _buildSummaryCard(
                        context,
                        title: 'Monthly Income',
                        value: provider.incomeRange != null
                            ? '${provider.selectedCurrency?.symbol ?? '\$'} ${provider.incomeRange}'
                            : 'Not selected',
                        icon: Icons.attach_money,
                        onEdit: () => _jumpToPage(context, 3),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Profile
                      _buildSummaryCard(
                        context,
                        title: 'Profile Details',
                        value: _getProfileSummary(provider),
                        icon: Icons.person,
                        onEdit: () => _jumpToPage(context, 4),
                        isMultiLine: true,
                      ),
                    ],
                  ),
                ),
              ),

              // Completion Note
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.success.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'You\'re all set! Tap "Complete Setup" to finish onboarding.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
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

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onEdit,
    bool isMultiLine = false,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  tooltip: 'Edit $title',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
              maxLines: isMultiLine ? null : 2,
              overflow: isMultiLine ? null : TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _getProfileSummary(OnboardingProvider provider) {
    final parts = <String>[];
    if (provider.ageRange != null) parts.add('Age: ${provider.ageRange}');
    if (provider.occupation != null) {
      parts.add('Occupation: ${provider.occupation}');
    }
    if (provider.location != null) {
      parts.add(
          'Location: ${provider.location!.city}, ${provider.location!.country}');
    }
    if (provider.riskTolerance != null) {
      parts.add('Risk: ${provider.riskTolerance}');
    }
    return parts.isNotEmpty ? parts.join('\n') : 'Not completed';
  }

  void _jumpToPage(BuildContext context, int page) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please use the back button to edit this section'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

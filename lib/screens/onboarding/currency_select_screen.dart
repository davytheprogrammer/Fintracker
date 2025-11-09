import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Finspense/shared/constants.dart';
import 'package:Finspense/models/user_model.dart';
import 'onboarding_provider.dart';

class CurrencySelectScreen extends StatelessWidget {
  const CurrencySelectScreen({Key? key}) : super(key: key);

  static const List<Map<String, String>> _currencies = [
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
    {'code': 'KES', 'symbol': 'KSh', 'name': 'Kenyan Shilling'},
    {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
    {'code': 'CAD', 'symbol': 'C\$', 'name': 'Canadian Dollar'},
    {'code': 'AUD', 'symbol': 'A\$', 'name': 'Australian Dollar'},
    {'code': 'CHF', 'symbol': 'CHF', 'name': 'Swiss Franc'},
    {'code': 'CNY', 'symbol': '¥', 'name': 'Chinese Yuan'},
    {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
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
                'Select Your Currency',
                style: AppTypography.headlineMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Subtitle
              Text(
                'Choose the currency you use most for your financial tracking',
                style: AppTypography.bodyLarge.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.7),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // Currency Dropdown
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: DropdownButtonFormField<Currency>(
                  initialValue: provider.selectedCurrency,
                  decoration: const InputDecoration(
                    labelText: 'Preferred Currency',
                    prefixIcon: Icon(Icons.currency_exchange),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                  ),
                  items: _currencies.map((currency) {
                    final curr = Currency(
                      code: currency['code']!,
                      symbol: currency['symbol']!,
                    );
                    return DropdownMenuItem<Currency>(
                      value: curr,
                      child: Row(
                        children: [
                          Text(
                            '${currency['symbol']} ',
                            style: AppTypography.titleMedium.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${currency['code']} - ${currency['name']}',
                            style: AppTypography.bodyMedium.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (Currency? value) {
                    if (value != null) {
                      provider.setCurrency(value);
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a currency';
                    }
                    return null;
                  },
                ),
              ),

              const Spacer(),

              // Selected Currency Display
              if (provider.selectedCurrency != null)
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
                        'Selected: ${provider.selectedCurrency!.symbol} ${provider.selectedCurrency!.code}',
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
}

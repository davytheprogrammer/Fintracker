import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Finspense/shared/constants.dart';
import 'package:Finspense/models/user_model.dart';
import 'onboarding_provider.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({Key? key}) : super(key: key);

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _occupationController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();

  static const List<String> _ageRanges = [
    '18-24',
    '25-34',
    '35-44',
    '45-54',
    '55-64',
    '65+',
  ];

  static const List<String> _riskTolerances = [
    'Conservative',
    'Moderate',
    'Aggressive',
  ];

  @override
  void initState() {
    super.initState();
    final provider = context.read<OnboardingProvider>();
    _occupationController.text = provider.occupation ?? '';
    if (provider.location != null) {
      _countryController.text = provider.location!.country;
      _cityController.text = provider.location!.city;
    }
  }

  @override
  void dispose() {
    _occupationController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<OnboardingProvider>();
      provider.setOccupation(_occupationController.text.trim());
      provider.setLocation(Location(
        country: _countryController.text.trim(),
        city: _cityController.text.trim(),
      ));
      // Age and risk are set via dropdowns
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            onChanged: _saveProfile,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xxl),

                // Title
                Text(
                  'Tell us about yourself',
                  style: AppTypography.headlineMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Subtitle
                Text(
                  'This information helps us personalize your experience',
                  style: AppTypography.bodyLarge.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),

                // Form Fields
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Age Range
                        DropdownButtonFormField<String>(
                          initialValue: provider.ageRange,
                          decoration: InputDecoration(
                            labelText: 'Age Range',
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          items: _ageRanges.map((range) {
                            return DropdownMenuItem<String>(
                              value: range,
                              child: Text(range),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            if (value != null) {
                              provider.setAgeRange(value);
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select your age range';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Occupation
                        TextFormField(
                          controller: _occupationController,
                          decoration: InputDecoration(
                            labelText: 'Occupation',
                            prefixIcon: const Icon(Icons.work),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your occupation';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Location
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _countryController,
                                decoration: InputDecoration(
                                  labelText: 'Country',
                                  prefixIcon: const Icon(Icons.flag),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.md),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your country';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: TextFormField(
                                controller: _cityController,
                                decoration: InputDecoration(
                                  labelText: 'City',
                                  prefixIcon: const Icon(Icons.location_city),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.md),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your city';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Risk Tolerance
                        DropdownButtonFormField<String>(
                          initialValue: provider.riskTolerance,
                          decoration: InputDecoration(
                            labelText: 'Risk Tolerance',
                            prefixIcon: const Icon(Icons.trending_up),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          items: _riskTolerances.map((tolerance) {
                            return DropdownMenuItem<String>(
                              value: tolerance,
                              child: Text(tolerance),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            if (value != null) {
                              provider.setRiskTolerance(value);
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select your risk tolerance';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Profile Summary
                if (provider.isProfileValid)
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
                          'Profile Summary',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Age: ${provider.ageRange ?? 'Not set'}\n'
                          'Occupation: ${provider.occupation ?? 'Not set'}\n'
                          'Location: ${provider.location?.city ?? 'Not set'}, ${provider.location?.country ?? 'Not set'}\n'
                          'Risk Tolerance: ${provider.riskTolerance ?? 'Not set'}',
                          style: AppTypography.bodySmall.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

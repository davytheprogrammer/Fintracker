import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Finspense/shared/constants.dart';
import 'package:Finspense/models/user_model.dart';
import 'package:Finspense/repositories/user_repository.dart';
import 'onboarding_provider.dart';
import 'welcome_screen.dart';
import 'currency_select_screen.dart';
import 'goals_select_screen.dart';
import 'income_select_screen.dart';
import 'profile_details_screen.dart';
import 'summary_screen.dart';

class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({Key? key}) : super(key: key);

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final UserRepository _userRepository = UserRepository();

  final List<Widget> _pages = [
    const WelcomeScreen(),
    const CurrencySelectScreen(),
    const GoalsSelectScreen(),
    const IncomeSelectScreen(),
    const ProfileDetailsScreen(),
    const SummaryScreen(),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppDurations.medium,
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: AppDurations.medium,
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int page) {
    debugPrint('Onboarding: Page changed to $page');
    setState(() {
      _currentPage = page;
    });
  }

  bool _canProceed(OnboardingProvider provider) {
    bool canProceed;
    switch (_currentPage) {
      case 0: // Welcome - always can proceed
        canProceed = true;
        break;
      case 1: // Currency
        canProceed = provider.isCurrencyValid;
        debugPrint('Onboarding: Currency valid: $canProceed');
        break;
      case 2: // Goals
        canProceed = provider.isGoalsValid;
        debugPrint(
            'Onboarding: Goals valid: $canProceed, goals: ${provider.selectedGoals}');
        break;
      case 3: // Income
        canProceed = provider.isIncomeValid;
        debugPrint(
            'Onboarding: Income valid: $canProceed, income: ${provider.incomeRange}');
        break;
      case 4: // Profile
        canProceed = provider.isProfileValid;
        debugPrint(
            'Onboarding: Profile valid: $canProceed, age: ${provider.ageRange}, occupation: ${provider.occupation}, location: ${provider.location?.city}, risk: ${provider.riskTolerance}');
        break;
      case 5: // Summary
        canProceed = provider.isComplete;
        debugPrint('Onboarding: Complete: $canProceed');
        break;
      default:
        canProceed = false;
    }
    return canProceed;
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentPage + 1) / _pages.length;

    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: _currentPage > 0
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _previousPage,
                  )
                : null,
            title: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            centerTitle: true,
          ),
          body: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: const NeverScrollableScrollPhysics(), // Disable swipe
            children: _pages,
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                if (_currentPage < _pages.length - 1)
                  Expanded(
                    child: TextButton(
                      onPressed: _canProceed(provider) ? _nextPage : null,
                      style: TextButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text(
                        'Next',
                        style: AppTypography.labelLarge.copyWith(
                          color: _canProceed(provider)
                              ? AppColors.primary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                if (_currentPage == _pages.length - 1)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _canProceed(provider)
                          ? () async {
                              try {
                                debugPrint('Onboarding: Starting to save data');
                                // Save onboarding data to Firestore
                                final user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  final userModel = UserModel(
                                    uid: user.uid,
                                    currency: provider.selectedCurrency,
                                    goals: provider.selectedGoals,
                                    incomeRange: provider.incomeRange,
                                    ageRange: provider.ageRange,
                                    occupation: provider.occupation,
                                    location: provider.location,
                                    riskTolerance: provider.riskTolerance,
                                  );
                                  debugPrint(
                                      'Onboarding: Saving user model to Firestore: ${userModel.toJson()}');
                                  await _userRepository
                                      .createOrUpdateUser(userModel);
                                  debugPrint(
                                      'Onboarding: Data saved successfully to Firestore');

                                  // Navigate to app
                                  debugPrint('Onboarding: Navigating to /app');
                                  if (context.mounted) {
                                    Navigator.of(context)
                                        .pushReplacementNamed('/app');
                                  }
                                } else {
                                  debugPrint('Onboarding: No user found');
                                  throw Exception('No authenticated user');
                                }
                              } catch (e) {
                                debugPrint('Onboarding: Error saving data: $e');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Failed to save onboarding data: $e'),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 5),
                                    ),
                                  );
                                }
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: const Text('Complete Setup'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

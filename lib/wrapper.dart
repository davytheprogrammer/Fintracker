// wrapper.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Finspense/app.dart';
import 'package:Finspense/screens/authentication/authenticate.dart';
import 'package:Finspense/screens/onboarding/onboarding_wrapper.dart';
import 'package:Finspense/screens/onboarding/onboarding_provider.dart';
import 'package:Finspense/models/the_user.dart';
import 'package:Finspense/providers/user_provider.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool _hasInitialized = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser?>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (user == null) {
      // Reset initialization flag when user logs out
      _hasInitialized = false;
      return const Authenticate();
    }

    // Initialize user provider with current user only once
    if (!_hasInitialized && user.uid != null && !userProvider.isAuthenticated) {
      _hasInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !userProvider.isAuthenticated) {
          debugPrint(
              'Wrapper: Initializing user provider for uid: ${user.uid}');
          userProvider.signIn(user.uid!);
        }
      });
    }

    // Use UserProvider to check onboarding status
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // Check if user is authenticated and has completed onboarding
        final hasCompletedOnboarding = userProvider.isAuthenticated &&
            userProvider.currentUser?.currency != null;

        debugPrint(
            'Wrapper: User authenticated: ${userProvider.isAuthenticated}, hasCompletedOnboarding: $hasCompletedOnboarding');

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: hasCompletedOnboarding
              ? const App()
              : ChangeNotifierProvider(
                  create: (_) => OnboardingProvider(),
                  child: const OnboardingWrapper(),
                ),
        );
      },
    );
  }
}

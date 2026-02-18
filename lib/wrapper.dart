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
  String? _lastInitializedUid;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser?>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (user == null) {
      // User logged out — reset tracked UID
      _lastInitializedUid = null;
      return const Authenticate();
    }

    // Initialize user provider only once per unique UID to prevent race conditions
    if (user.uid != null &&
        user.uid != _lastInitializedUid &&
        !userProvider.isAuthenticated) {
      _lastInitializedUid = user.uid;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !userProvider.isAuthenticated) {
          debugPrint('Wrapper: Initializing user provider for uid: ${user.uid}');
          userProvider.signIn(user.uid!);
        }
      });
    }

    // Show loading indicator during auth state transitions
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final hasCompletedOnboarding = userProvider.isAuthenticated &&
            userProvider.currentUser?.currency != null;

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

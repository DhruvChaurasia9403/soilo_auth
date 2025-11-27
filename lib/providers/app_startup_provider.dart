// lib/providers/app_startup_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/auth/auth_repository.dart';
import '../models/auth/user_role.dart';
import '../routes/router.dart';
import '../controllers/auth/signup_controller.dart'; // For shouldShowOnboardingProvider

// This provider handles the logic to check profile status on App Start
final appStartupProvider = FutureProvider<void>((ref) async {
  // 1. Watch for Auth Changes
  final authState = await ref.watch(authStateProvider.future);

  // 2. If no user, we are done (Router will send to Login)
  if (authState == null) return;

  // 3. If User exists, Fetch Profile
  final authRepo = ref.read(authRepositoryProvider);
  try {
    final profileData = await authRepo.getUserProfile(authState.uid);

    // 4. Check Onboarding Status
    final bool isOnboardingComplete = profileData?['isOnboardingComplete'] ?? false;
    final String? roleString = profileData?['role'];

    // If they are a Farmer and NOT complete, set the flags
    if (!isOnboardingComplete && roleString == 'farmer') {

      final fullName = profileData?['fullName'] ?? '';
      final role = UserRole.farmer;

      // Update the providers needed for the Onboarding Screen
      ref.read(onboardingDataProvider.notifier).state = {
        'fullName': fullName,
        'role': role,
      };

      ref.read(shouldShowOnboardingProvider.notifier).state = true;
    } else {
      // Ensure flag is false if they are done
      ref.read(shouldShowOnboardingProvider.notifier).state = false;
    }
  } catch (e) {
    // If fetch fails (offline?), we might want to default to Home or Retry.
    // For now, logging error.
    print("Startup Profile Fetch Failed: $e");
  }
});
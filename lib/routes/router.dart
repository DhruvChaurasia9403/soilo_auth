import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Screen Imports
import '../providers/app_startup_provider.dart';
import '../controllers/auth/signup_controller.dart';
import '../providers/flow_flags/reset_flow_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/onboarding/farmer_onboarding_screen.dart';
import '../models/auth/user_role.dart';
import '../utils/ui_helpers.dart';


// --- 1. Auth State Provider ---
final authStateProvider = StreamProvider<User?>(
      (ref) => FirebaseAuth.instance.authStateChanges(),
);

// --- 2. Flow Guard Notifier ---
class AuthFlowNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setFlow(bool value) {
    state = value;
  }
}
final shouldShowOnboardingProvider = StateProvider<bool>((ref) => false);


final isAuthFlowInProgressProvider =
NotifierProvider<AuthFlowNotifier, bool>(() {
  return AuthFlowNotifier();
});

// --- 3. Router Notifier ---
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<User?>>(
      authStateProvider,
          (_, __) => notifyListeners(),
    );
    _ref.listen<bool>(
      isAuthFlowInProgressProvider,
          (_, __) => notifyListeners(),
    );

    //A IMp change

    _ref.listen<bool>(
      resetFlowPersistenceProvider,
          (_, __) => notifyListeners(),
    );
    _ref.listen(shouldShowOnboardingProvider, (_, __) => notifyListeners());
    _ref.listen(appStartupProvider, (_, __) => notifyListeners());
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authStateProvider);
    final isFlowInProgress = _ref.read(isAuthFlowInProgressProvider);
    final isResetPersisted = _ref.read(resetFlowPersistenceProvider);
    final shouldShowOnboarding = _ref.read(shouldShowOnboardingProvider);
    final isAuth = authState.asData?.value != null;
    final location = state.matchedLocation;
    // 1. PRIORITY: If flow is in progress, ALLOW EVERYTHING.
    if (isAuth && isResetPersisted) {
      // If they are already there, let them stay. If not, move them there.
      return location == '/reset-password' ? null : '/reset-password';
    }
    if (isFlowInProgress) return null;
    final startupState = _ref.read(appStartupProvider);
    if (startupState.isLoading || startupState.hasError) {
      return null;
    }

    // Define public routes
    final isLoginRoute = location == '/login';
    final isSignUpRoute = location == '/signup';
    final isForgotPassRoute = location == '/forgot-password';
    final isOtpRoute = location == '/otp-verification';
    final isResetRoute = location == '/reset-password';
    final isOnboardingRoute = location == '/onboarding'; // Include new route

    final isAuthRoute = isLoginRoute || isSignUpRoute || isForgotPassRoute || isOtpRoute;

    // 2. UNAUTHENTICATED LOGIC
    if (!isAuth) {
      // 👇 CRITICAL FIX:
      // If they are on Reset Password, but the FLAG IS GONE (Controller deleted it),
      // it means they finished. Kick them to login.
      if (isResetRoute && !isResetPersisted) {
        return '/login';
      }

      // Allow standard auth routes and the onboarding route (it has internal guards)
      if (isAuthRoute || isResetRoute || isOnboardingRoute) return null;

      return '/login';
    }

    // 3. AUTHENTICATED LOGIC
    if (isAuth) {
      // --- IMPORTANT FIX: Allow onboarding immediately after farmer signup ---
      if (shouldShowOnboarding) {
        if (location != '/onboarding') {
          return '/onboarding';
        }
        return null; // allow onboarding screen
      }

      // Block access to auth routes
      if (isAuthRoute && !isOtpRoute) {
        return '/home';
      }
    }

    return null;
  }
}

// --- 4. Router Provider ---
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/login', // RESTORED: Back to standard login
    debugLogDiagnostics: true,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      // --- PRODUCTION: Farmer Onboarding Route (Used after Farmer Signup) ---
      GoRoute(
        path: '/onboarding',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;

          final dataProvider = ref.read(onboardingDataProvider);

          // Combine sources
          final dataSource = extra ?? dataProvider;

          final fullName = dataSource?['fullName'] as String?;
          final role = dataSource?['role'] as UserRole?;

          // Check validity
          if (fullName == null || role == null || role != UserRole.farmer) {
            // If data is missing, we must fail gracefully
            return const LoginScreen();
          }

          return FarmerOnboardingScreen(
            fullName: fullName,
            role: role,
          );
        },
      ),
      GoRoute(
        path: '/otp-verification',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;

          final purpose = extra?['purpose'] as VerificationPurpose? ??
              VerificationPurpose.signUp;

          final verificationId = extra?['verificationId'] as String? ?? '';
          final phoneNumber = extra?['phoneNumber'] as String? ?? '';
          // Extract Password passed from Login Screen
          final password = extra?['password'] as String?;

          if (verificationId.isEmpty) {
            return const LoginScreen();
          }

          return OtpVerificationScreen(
            verificationId: verificationId,
            phoneNumber: phoneNumber,
            purpose: purpose,
            password: password, // Pass it to the screen
          );
        },
      ),
    ],
  );
});
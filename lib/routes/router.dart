import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Screen Imports
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/auth/signup_screen.dart' show VerificationPurpose;

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
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authStateProvider);
    final isFlowInProgress = _ref.read(isAuthFlowInProgressProvider);

    final isAuth = authState.asData?.value != null;
    final location = state.matchedLocation;

    // 1. PRIORITY: If flow is in progress, ALLOW EVERYTHING.
    if (isFlowInProgress) return null;

    // Define public routes
    final isLoginRoute = location == '/login';
    final isSignUpRoute = location == '/signup';
    final isForgotPassRoute = location == '/forgot-password';
    final isOtpRoute = location == '/otp-verification';
    final isResetRoute = location == '/reset-password';

    final isAuthRoute = isLoginRoute || isSignUpRoute || isForgotPassRoute || isOtpRoute;

    // 2. UNAUTHENTICATED LOGIC
    if (!isAuth) {
      // Allow access to auth pages and reset password page
      if (isAuthRoute || isResetRoute) {
        return null;
      }
      // Otherwise, go to login
      return '/login';
    }

    // 3. AUTHENTICATED LOGIC
    if (isAuth) {
      // If user is logged in, they are fully verified (because of our Controller fix).
      // So redirect them to home if they try to access auth pages.
      if (isAuthRoute && !isResetRoute && !isOtpRoute) {
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
    initialLocation: '/login',
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
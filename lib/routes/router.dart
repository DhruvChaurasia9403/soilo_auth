import 'package:checking/screens/auth/forgot_password_screen.dart';
import 'package:checking/screens/auth/login_screen.dart';
import 'package:checking/screens/auth/otp_verification_screen.dart';
import 'package:checking/screens/auth/signup_screen.dart';
import 'package:checking/screens/home/home_screen.dart';
import 'package:checking/screens/auth/reset_password_screen.dart'; // 👈 ADD
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

// --- PROVIDER that listens to FirebaseAuth user changes ---
final authStateProvider = StreamProvider<User?>(
      (ref) => FirebaseAuth.instance.authStateChanges(),
);


// --- ROUTER PROVIDER ---
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
    redirect: (context, state) {
      final isAuth = authState.asData?.value != null;
      final authRoutes = [
        '/login',
        '/signup',
        '/forgot-password',
        '/otp-verification'
      ];
      final onAuthRoute = authRoutes.contains(state.matchedLocation);
      final onResetRoute = state.matchedLocation == '/reset-password';
      if (isAuth) {
        if (onAuthRoute) {
          return '/home';
        }
        return null;
      }
      // this was the flawed code, because isloggingin and isresettingpassword were nested like suppose if person is resetting then he will be !islogginingin that means the if condition will terminate and return /login route even if he is resetting password
      // if (isAuth && isLoggingIn) {
      //   if(isResettingPassword){
      //     return null;
      //   }
      //   return '/home';
      // }
      if (!isAuth) {
        if (onAuthRoute || onResetRoute) {
          return null;
        }
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      // ⭐ NEW: Reset Password Route
      GoRoute(
        path: '/reset-password',
        name: 'resetPassword',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      // ⭐ UPDATED: OTP Verification Route
      GoRoute(
        path: '/otp-verification',
        name: 'otpVerification',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;

          // Default to signUp just in case, but it should always be provided
          final purpose = extra?['purpose'] as VerificationPurpose? ??
              VerificationPurpose.signUp;

          final verificationId = extra?['verificationId'] as String? ?? '';
          final phoneNumber = extra?['phoneNumber'] as String? ?? '';

          if (verificationId.isEmpty) {
            // If we're missing a verification ID, we can't do anything.
            // Go back to login.
            return const LoginScreen();
          }

          return OtpVerificationScreen(
            verificationId: verificationId,
            phoneNumber: phoneNumber,
            purpose: purpose,
          );
        },
      ),
    ],
  );
});

// --- Helper to automatically rebuild router when auth changes ---
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
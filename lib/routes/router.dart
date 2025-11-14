import 'package:checking/screens/auth/forgot_password_screen.dart';
import 'package:checking/screens/auth/login_screen.dart';
import 'package:checking/screens/auth/otp_verification_screen.dart';
import 'package:checking/screens/auth/signup_screen.dart';
import 'package:checking/screens/home/home_screen.dart';
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

    // Listen to auth state changes
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),

    redirect: (context, state) {
      final isAuth = authState.asData?.value != null;
      final isLoggingIn =
          state.uri.toString() == '/login' ||
          state.uri.toString() == '/signup' ||
          state.uri.toString() == '/forgot-password' ||
          state.uri.toString() == '/otp-verification';

      if (!isAuth && !isLoggingIn) {
        // User not logged in → redirect to login
        return '/login';
      }

      if (isAuth && isLoggingIn) {
        // User logged in → redirect to home
        return '/home';
      }

      return null; // stay on current route
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
      GoRoute(
        path: '/otp-verification',
        name: 'otpVerification',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;

          final verificationId = extra?['verificationId'] ?? '';
          final phoneNumber = extra?['phoneNumber'] ?? '';

          return OtpVerificationScreen(
            verificationId: verificationId,
            phoneNumber: phoneNumber,
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

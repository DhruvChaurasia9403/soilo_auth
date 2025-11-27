import 'package:checking/controllers/auth/signup_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/auth/auth_repository.dart';
import '../../models/auth/user_role.dart';
import '../../routes/router.dart';
import '../../providers/flow_flags/login_flow_provider.dart';

class LoginController extends AsyncNotifier<String?> {
  String? _pendingPhone;
  String? _pendingPassword; // 👈 Added to store password

  @override
  String? build() => null;

  // --- 1. INITIAL LOGIN (Checks Password + Sends OTP) ---
  Future<void> sendOtpForLogin({
    required String phoneNumber,
    required String password,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    Function(String verificationId)? onAutoRetrievalTimeout,
  }) async {
    state = const AsyncValue.loading();
    _pendingPhone = phoneNumber;
    _pendingPassword = password; // Store for later use

    ref.read(isAuthFlowInProgressProvider.notifier).setFlow(true);
    final authRepository = ref.read(authRepositoryProvider);

    try {
      // 1. Set Dirty Flag
      await ref.read(loginFlowPersistenceProvider.notifier).setPending(true);

      await authRepository.signInWithPhonePassword(phoneNumber, password);

      // DON'T REMOVE BELOW TWO COMMENTS AS THEY ARE NECESSARY FOR FUTURE DEV WORKS
      // Force Sign out to keep session clean (Triggers Auth Change)
      // await FirebaseAuth.instance.signOut();

      // 3. Send OTP
      await _sendOtpInternal(phoneNumber, onCodeSent, onError, onAutoRetrievalTimeout);

    } on FirebaseAuthException catch (e) {
      await _cleanupSession();
      String msg = e.message ?? 'Login failed';
      if (e.code == 'wrong-password') msg = 'Incorrect Password.';
      if (e.code == 'user-not-found') msg = 'Account not found.';
      onError(msg);
      state = AsyncValue.error(msg, StackTrace.current);
    } catch (e) {
      await _cleanupSession();
      onError(e.toString());
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // --- 2. RESEND OTP (Skips Password Check) ---
  // This avoids triggering AuthState changes, preserving Router state.
  Future<void> resendOtp({
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    Function(String verificationId)? onAutoRetrievalTimeout,
  }) async {
    if (_pendingPhone == null) {
      onError("Session expired. Please login again.");
      return;
    }

    state = const AsyncValue.loading();
    await _sendOtpInternal(_pendingPhone!, onCodeSent, onError, onAutoRetrievalTimeout);
  }

  // Helper for shared OTP sending logic
  Future<void> _sendOtpInternal(
      String phoneNumber,
      Function(String) onCodeSent,
      Function(String) onError,
      Function(String)? onAutoRetrievalTimeout
      ) async {
    final authRepository = ref.read(authRepositoryProvider);
    try {
      await authRepository.verifyPhoneNumber(
        phoneNumber,
        verificationFailed: (e) {
          _cleanupSession();
          final errorMsg = e.message ?? 'Verification failed.';
          onError(errorMsg);
          state = AsyncValue.error(errorMsg, StackTrace.current);
        },
        codeSent: (verificationId, resendToken) {
          state = AsyncValue.data(verificationId);
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (verificationId) {
          print("In login controller");
          state = AsyncValue.data(verificationId);
          if (onAutoRetrievalTimeout != null) {
            onAutoRetrievalTimeout(verificationId);
          }
        },
      );
    } catch (e) {
      onError(e.toString());
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // --- 3. COMPLETE LOGIN ---
  Future<void> completeLoginWithOtp({
    required String verificationId,
    required String smsCode,
    String? password // Optional now, can use pending
  }) async {
    state = const AsyncValue.loading();
    final authRepository = ref.read(authRepositoryProvider);
    final pwd = password ?? _pendingPassword;
    if (pwd == null || _pendingPhone == null) {
      state = AsyncValue.error("Missing credentials", StackTrace.current);
      return;
    }

    try {
      // 1. Sign in with Password (REAL LOGIN)
      authRepository.signInWithPhonePassword(_pendingPhone!, pwd);
      final credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode
      );
      await authRepository.updatePhoneCredential(credential);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not found after login");

      final profileData = await authRepository.getUserProfile(user.uid);

      // 3. Logic: Check if Onboarding is complete
      // Default to 'false' if the field is missing
      final bool isOnboardingComplete = profileData?['isOnboardingComplete'] ?? false;

      if (!isOnboardingComplete && profileData != null) {
        // ⚠️ User is logged in but hasn't finished onboarding.

        // Extract data needed for the onboarding screen
        final String fullName = profileData['fullName'] ?? '';
        final String roleString = profileData['role'] ?? 'farmer';

        // Convert string to Enum safely
        final role = UserRole.values.firstWhere(
              (e) => e.name == roleString,
          orElse: () => UserRole.farmer,
        );

        // Populate the Data Provider so the Router can read it
        ref.read(onboardingDataProvider.notifier).state = {
          'fullName': fullName,
          'role': role,
        };

        // Set the Flag to force redirection
        ref.read(shouldShowOnboardingProvider.notifier).state = true;
      } else {
        // User is fully onboarded -> Ensure flag is false
        ref.read(shouldShowOnboardingProvider.notifier).state = false;
      }

      // Cleanup
      await ref.read(loginFlowPersistenceProvider.notifier).setPending(false);
      _pendingPhone = null;
      _pendingPassword = null;

      ref.read(isAuthFlowInProgressProvider.notifier).setFlow(false);
      state = const AsyncValue.data(null);

    } on FirebaseAuthException catch (e) {
      await _cleanupSession();
      state = AsyncValue.error(e.message ?? 'OTP verification failed', StackTrace.current);
    } catch (e) {
      await _cleanupSession();
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> _cleanupSession() async {
    await FirebaseAuth.instance.signOut();
    ref.read(isAuthFlowInProgressProvider.notifier).setFlow(false);
    await ref.read(loginFlowPersistenceProvider.notifier).setPending(false);
  }
}

final loginControllerProvider = AsyncNotifierProvider<LoginController, String?>(() {
  return LoginController();
});
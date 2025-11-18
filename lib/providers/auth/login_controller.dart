// lib/features/auth/login_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/auth_repository.dart';
import '../../routes/router.dart'; // Needed to set the flow flag

class LoginController extends AsyncNotifier<String?> {
  String? _pendingPhone;
  // We don't need _pendingPassword anymore because we verify it in Step 1

  @override
  String? build() => null;

  /// Step 1: Check Password FIRST, then send OTP
  Future<void> sendOtpForLogin({
    required String phoneNumber,
    required String password,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    state = const AsyncValue.loading();
    final authRepository = ref.read(authRepositoryProvider);

    _pendingPhone = phoneNumber;

    // 1. 🛑 SIGNAL ROUTER: "I am logging in, but don't go to Home yet."
    // We set this BEFORE the password check so the router doesn't redirect
    // immediately upon successful password login.
    ref.read(isAuthFlowInProgressProvider.notifier).setFlow(true);

    try {
      // 2. 🔐 PASSWORD CHECK (Pseudo-Email Strategy)
      // We check the password against Firebase BEFORE sending SMS.
      // This saves SMS costs and prevents spam.
      final pseudoEmail = '$phoneNumber@soilo.app';

      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: pseudoEmail,
          password: password
      );

      // 3. 📨 SEND OTP (2FA)
      // If we reached here, Password was correct. Now verify the device.
      await authRepository.verifyPhoneNumber(
        phoneNumber,
        verificationFailed: (e) {
          // If SMS fails, sign out immediately so they aren't left logged in
          FirebaseAuth.instance.signOut();
          ref.read(isAuthFlowInProgressProvider.notifier).setFlow(false);

          final errorMsg = e.message ?? 'Phone verification failed.';
          onError(errorMsg);
          state = AsyncValue.error(errorMsg, StackTrace.current);
        },
        codeSent: (verificationId, resendToken) {
          state = AsyncValue.data(verificationId);
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (verificationId) {
          state = AsyncValue.data(verificationId);
        },
      );

    } on FirebaseAuthException catch (e) {
      // Authentication failed (Wrong password or User not found)
      // Ensure we are signed out and reset flow
      FirebaseAuth.instance.signOut();
      ref.read(isAuthFlowInProgressProvider.notifier).setFlow(false);

      // Provide user-friendly error messages
      String msg = e.message ?? 'Login failed';
      if (e.code == 'wrong-password') msg = 'Incorrect Password.';
      if (e.code == 'user-not-found') msg = 'Account not found.';

      onError(msg);
      state = AsyncValue.error(msg, StackTrace.current);
    } catch (e) {
      FirebaseAuth.instance.signOut();
      ref.read(isAuthFlowInProgressProvider.notifier).setFlow(false);
      onError(e.toString());
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Step 2: after OTP entered — verify the phone credential
  Future<void> completeLoginWithOtp(String verificationId, String smsCode) async {
    state = const AsyncValue.loading();

    try {
      // Create the Phone Credential
      final credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode
      );

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // We are already signed in via Password (from Step 1).
        // Now we update/link the phone number to prove ownership of the device.
        // This acts as the "2nd Factor" verification.
        await user.updatePhoneNumber(credential);
      } else {
        // Edge case: User somehow lost session between Step 1 and 2.
        // Fallback to standard sign in.
        final authRepository = ref.read(authRepositoryProvider);
        await authRepository.signInWithPhoneNumberAndOtp(verificationId, smsCode);
      }

      // 🎉 SUCCESS
      // Clear the pending data
      _pendingPhone = null;

      // Turn off the flow flag so the Router finally redirects to /home
      ref.read(isAuthFlowInProgressProvider.notifier).setFlow(false);

      state = const AsyncValue.data(null);

    } on FirebaseAuthException catch (e) {
      // If OTP failed, do NOT sign out immediately?
      // Actually, yes, strictly speaking 2FA failed, so session is invalid.
      await FirebaseAuth.instance.signOut();
      ref.read(isAuthFlowInProgressProvider.notifier).setFlow(false);

      state = AsyncValue.error(e.message ?? 'OTP verification failed', StackTrace.current);
    } catch (e) {
      await FirebaseAuth.instance.signOut();
      ref.read(isAuthFlowInProgressProvider.notifier).setFlow(false);
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Provider
final loginControllerProvider = AsyncNotifierProvider<LoginController, String?>(() {
  return LoginController();
});
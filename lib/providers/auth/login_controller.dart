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
    ref.read(isAuthFlowInProgressProvider.notifier).setFlow(true);

    try {
      // 2. 🔐 PASSWORD CHECK (Pseudo-Email Strategy)
      // We check the password against Firebase BEFORE sending SMS.


      // A. Sign in to validate password
      await authRepository.signInWithPhonePassword(phoneNumber, password);

      // B. 🛑 IMMEDIATE SIGN OUT (The Fix)
      // We sign out so if the app is killed here, the user is NOT logged in.
      // This forces them to restart the flow if they quit before OTP.
      await authRepository.signOut();

      // 3. 📨 SEND OTP (2FA)
      await authRepository.verifyPhoneNumber(
        phoneNumber,
        verificationFailed: (e) {
          // Reset flow if verification fails
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
      FirebaseAuth.instance.signOut();
      ref.read(isAuthFlowInProgressProvider.notifier).setFlow(false);

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
  /// We now need the PASSWORD here to sign them in for real.
  Future<void> completeLoginWithOtp({
    required String verificationId,
    required String smsCode,
    required String password, // 👈 New Argument
  }) async {
    state = const AsyncValue.loading();

    try {
      // 1. Re-Authenticate with Password (since we signed out in Step 1)
      // We know _pendingPhone is set from Step 1
      if (_pendingPhone == null) throw Exception("Session expired. Please login again.");

      final pseudoEmail = '$_pendingPhone@soilo.app';

      // This performs the REAL, Persistent login
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: pseudoEmail,
          password: password
      );

      final user = userCredential.user;

      // 2. Verify/Link Phone (2FA check)
      // This proves they have the device
      if (user != null) {
        final credential = PhoneAuthProvider.credential(
            verificationId: verificationId,
            smsCode: smsCode
        );
        // Update the phone number to link this specific OTP session
        // (or just to verify the credential is valid)
        await user.updatePhoneNumber(credential);
      }

      // 🎉 SUCCESS
      _pendingPhone = null;

      // Turn off the flow flag so the Router finally redirects to /home
      ref.read(isAuthFlowInProgressProvider.notifier).setFlow(false);

      state = const AsyncValue.data(null);

    } on FirebaseAuthException catch (e) {
      // If OTP failed, ensure we stay signed out
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
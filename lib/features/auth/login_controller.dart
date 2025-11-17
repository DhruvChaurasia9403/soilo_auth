import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_repository.dart';

// LoginController will hold the verificationId for the OTP screen
class LoginController extends AsyncNotifier<String?> {
  @override
  String? build() {
    return null; // Initial state: no verification ID
  }

  Future<void> signInAndVerifyPhone({
    required String phoneNumber,
    required String password,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    state = const AsyncValue.loading();
    final authRepository = ref.read(authRepositoryProvider);

    try {
      // Step 1: Try to sign in with Phone/Password
      await authRepository.signInWithPhonePassword(phoneNumber, password);

      // Step 2: If sign-in is successful, send an OTP
      await authRepository.verifyPhoneNumber(
        phoneNumber,
        verificationFailed: (e) {
          final errorMsg = e.message ?? 'Phone verification failed.';
          onError(errorMsg);
          state = AsyncValue.error(errorMsg, StackTrace.current);
        },
        codeSent: (verificationId, resendToken) {
          state = AsyncValue.data(verificationId); // Store verification ID
          onCodeSent(verificationId); // Trigger navigation to OTP screen
        },
        codeAutoRetrievalTimeout: (verificationId) {
          state = AsyncValue.data(verificationId); // Keep verification ID
        },
      );
    } on Exception catch (e) {
      onError(e.toString());
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Call this after successful OTP verification
  Future<void> completeLoginWithOtp(String verificationId, String smsCode) async {
    state = const AsyncValue.loading();
    final authRepository = ref.read(authRepositoryProvider);
    try {
      // Sign in with phone OTP. This will complete the login.
      await authRepository.signInWithPhoneNumberAndOtp(verificationId, smsCode);
      state = const AsyncValue.data(null); // Success
    } on Exception catch (e) {
      // ⭐ FIX: Corrected StackTrace typo
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final loginControllerProvider =
AsyncNotifierProvider<LoginController, String?>(() {
  return LoginController();
});
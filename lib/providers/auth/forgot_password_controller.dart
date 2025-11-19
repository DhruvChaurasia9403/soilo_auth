// lib/features/auth/forgot_password_controller.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/auth_repository.dart';
import '../reset_flow_provider.dart';

// This controller will hold the verificationId
class ForgotPasswordController extends AsyncNotifier<String?> {
  @override
  String? build() {
    return null; // Initial state: no verification ID
  }

  // This method now sends an OTP for password reset
  Future<void> sendVerificationOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    state = const AsyncValue.loading();
    final authRepository = ref.read(authRepositoryProvider);

    try {
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
          // onCodeSent(verificationId);
        },
      );
    } on Exception catch (e) {
      onError(e.toString());
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // This method is for completing the OTP verification for reset flow
  // It signs the user in (temporarily) so they can update their password
  Future<void> verifyOtpAndSignIn(String verificationId, String smsCode) async {
    state = const AsyncValue.loading();
    final authRepository = ref.read(authRepositoryProvider);
    try {
      // Sign in with phone OTP. This authenticates the user
      // so they have permission to change their password.
      await authRepository.signInWithPhoneNumberAndOtp(verificationId, smsCode);
      ref.read(resetFlowPersistenceProvider.notifier).setResetFlow(true);
      // Keep state data null but indicate success
      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } on Exception catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Must not be .autoDispose so verificationId persists during OTP flow
final forgotPasswordControllerProvider =
AsyncNotifierProvider<ForgotPasswordController, String?>(() {
  return ForgotPasswordController();
});

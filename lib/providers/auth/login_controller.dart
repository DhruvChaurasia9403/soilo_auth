// lib/features/auth/login_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../features/auth/auth_repository.dart';


class LoginController extends AsyncNotifier<String?> {
  String? _pendingPhone;
  String? _pendingPassword;

  @override
  String? build() => null;

  /// Step 1: send OTP and save pending data (do NOT sign in here)
  Future<void> sendOtpForLogin({
    required String phoneNumber,
    required String password,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    state = const AsyncValue.loading();
    final authRepository = ref.read(authRepositoryProvider);

    _pendingPhone = phoneNumber;
    _pendingPassword = password;

    try {
      await authRepository.verifyPhoneNumber(
        phoneNumber,
        verificationFailed: (e) {
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
    } on Exception catch (e) {
      onError(e.toString());
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Step 2: after OTP entered — sign in using phone OTP credential
  Future<void> completeLoginWithOtp(String verificationId, String smsCode) async {
    state = const AsyncValue.loading();
    final authRepository = ref.read(authRepositoryProvider);

    try {
      // Sign in with the phone credential (OTP)
      await authRepository.signInWithPhoneNumberAndOtp(verificationId, smsCode);

      // Optionally: you could also verify password by calling signInWithPhonePassword
      // using the phone-derived email + _pendingPassword, but OTP-only login is common.

      // clear pending values
      _pendingPhone = null;
      _pendingPassword = null;

      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } on Exception catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Provider (do NOT autoDispose to preserve pending data during OTP flow)
final loginControllerProvider =
AsyncNotifierProvider<LoginController, String?>(() {
  return LoginController();
});

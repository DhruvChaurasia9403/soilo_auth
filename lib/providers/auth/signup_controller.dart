// lib/features/auth/signup_controller.dart
import 'package:checking/features/auth/user_role.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../features/auth/auth_repository.dart';
import '../../routes/router.dart';

// Holds the data needed for the onboarding screen so the Router can access it
final onboardingDataProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

class SignUpController extends AsyncNotifier<String?> {
  // Will hold verificationId (state) AND pending sign-up details
  String? _pendingFullName;
  String? _pendingPassword;
  String? _pendingPhone;
  UserRole? _pendingRole;

  @override
  String? build() {
    return null; // initial: no verificationId
  }

  /// Step 1: send OTP and save pending data (do NOT create Firebase user here)
  Future<void> signUpAndVerifyPhone({
    required String fullName,
    required String password,
    required String phoneNumber,
    required UserRole role,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    // 1. Store pending values first
    _pendingFullName = fullName;
    _pendingPassword = password;
    _pendingPhone = phoneNumber;
    _pendingRole = role;

    // 2. Call the shared verification method
    await _startPhoneVerification(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onError: onError,
    );
  }

  /// NEW: Resend OTP using stored pending phone number
  Future<void> resendOtp({
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    // Guard: Ensure we have the phone number in memory
    if (_pendingPhone == null) {
      const errorMsg = "Session expired. Please restart the sign-up process.";
      onError(errorMsg);
      state = AsyncValue.error(errorMsg, StackTrace.current);
      return;
    }

    // Call the shared verification method with the stored phone
    await _startPhoneVerification(
      phoneNumber: _pendingPhone!,
      onCodeSent: onCodeSent,
      onError: onError,
    );
  }

  /// PRIVATE HELPER: Handles the actual Firebase verification logic
  Future<void> _startPhoneVerification({
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
          state = AsyncValue.data(verificationId);
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (verificationId) {
          // Treat timeout as success for manual entry
          state = AsyncValue.data(verificationId);
          // onCodeSent(verificationId);
        },
      );
    } on Exception catch (e) {
      onError(e.toString());
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  /// Step 2: after OTP entered — create Firebase user and link phone credential
  Future<void> completeSignUpWithOtp(String verificationId, String smsCode) async {
    state = const AsyncValue.loading(); //
    final authRepository = ref.read(authRepositoryProvider); //

    try {
      // Build phone credential from verificationId & smsCode (do NOT sign-in with this)
      final phoneCredential = PhoneAuthProvider.credential( //
        verificationId: verificationId, //
        smsCode: smsCode, //
      );

      // Validate pending fields
      if (_pendingPhone == null || //
          _pendingPassword == null || //
          _pendingFullName == null || //
          _pendingRole == null) { //
        throw Exception('Missing pending signup data.'); //
      }

      // 1) Create the email/password account (this signs in the new user)
      final userCredential = await authRepository.signUpWithPhonePassword( //
        _pendingPhone!, //
        _pendingPassword!, //
      );

      final user = userCredential.user; //
      if (user == null) throw Exception('Failed to create user.'); //

      // 2) Link the phone credential to the newly created user
      await user.linkWithCredential(phoneCredential); //

      // 3) Create Firestore profile
      await authRepository.createUserProfile( //
        uid: user.uid, //
        fullName: _pendingFullName!, //
        phoneNumber: _pendingPhone!, //
        role: _pendingRole!, //
      );

      // NEW: Pass data to state so the UI can redirect
      if (_pendingRole == UserRole.farmer) {
        ref.read(onboardingDataProvider.notifier).state = {
          'fullName': _pendingFullName,
          'role': _pendingRole,
        };
        // Pass required data for onboarding
        ref.read(shouldShowOnboardingProvider.notifier).state = true;
        state = AsyncValue.data('onboarding|${_pendingFullName}|${_pendingRole!.name}');
      } else {
        // Default success state
        state = const AsyncValue.data(null);
      }

      // clear pending values
      _pendingFullName = null; //
      _pendingPassword = null; //
      _pendingPhone = null; //
      _pendingRole = null; //

    } on FirebaseAuthException catch (e) { //
      // Return firebase-specific errors
      state = AsyncValue.error(e, StackTrace.current); //
    } on Exception catch (e) { //
      state = AsyncValue.error(e, StackTrace.current); //
    }
  }
}

// Provider (do NOT autoDispose to preserve pending data during OTP flow)
final signUpControllerProvider =
AsyncNotifierProvider<SignUpController, String?>(() {
  return SignUpController();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_repository.dart';
import 'user_role.dart'; // 👈 ADD

// Renamed from AsyncNotifier to AsyncNotifier
class SignUpController extends AsyncNotifier<String?> {
  // State will hold the verificationId for OTP screen, or null
  @override
  String? build() {
    return null; // Initial state: no verification ID
  }

  // UPDATED: New signature
  Future<void> signUpAndVerifyPhone({
    required String fullName, // 👈 ADD
    required String password,
    required String phoneNumber,
    required UserRole role, // 👈 ADD
    required Function(String verificationId) onCodeSent, // Callback to navigate to OTP screen
    required Function(String error) onError,
  }) async {
    state = const AsyncValue.loading(); // Indicate loading

    final authRepository = ref.read(authRepositoryProvider);

    try {
      // Step 1: Create user with Phone/Password
      final userCredential = await authRepository.signUpWithPhonePassword(phoneNumber, password);

      if (userCredential.user == null) {
        throw Exception('User creation failed.');
      }

      final uid = userCredential.user!.uid;

      // Step 2: Create user profile in Firestore
      await authRepository.createUserProfile(
        uid: uid,
        fullName: fullName,
        phoneNumber: phoneNumber,
        role: role,
      );

      // Step 3: Verify phone number
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
  Future<void> completeSignUpWithOtp(String verificationId, String smsCode) async {
    state = const AsyncValue.loading();
    final authRepository = ref.read(authRepositoryProvider);
    try {
      // Sign in with phone OTP. This will authenticate the user.
      await authRepository.signInWithPhoneNumberAndOtp(verificationId, smsCode);
      // On success, the authStateChanges stream will fire.
      // GoRouter will automatically navigate to the home screen.
      state = const AsyncValue.data(null); // Success
    } on Exception catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// ⭐ CRITICAL CHANGE: Removed .autoDispose
final signUpControllerProvider =
AsyncNotifierProvider<SignUpController, String?>(() {
  return SignUpController();
});
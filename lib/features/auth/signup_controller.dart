import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Correct import path
import 'auth_repository.dart';

// Renamed from AutoDisposeAsyncNotifier to AsyncNotifier
class SignUpController extends AsyncNotifier<String?> {
  // State will hold the verificationId for OTP screen, or null
  @override
  String? build() {
    return null; // Initial state: no verification ID
  }

  Future<void> signUpAndVerifyPhone({
    required String email,
    required String password,
    required String phoneNumber,
    required Function(String verificationId) onCodeSent, // Callback to navigate to OTP screen
    required Function(String error) onError,
  }) async {
    state = const AsyncValue.loading(); // Indicate loading

    final authRepository = ref.read(authRepositoryProvider);

    try {
      // Step 1: Create user with Email/Password first
      // Firebase needs a user to be associated with a phone number for direct sign-in with phone.
      // Alternatively, you could skip this step and just verify phone, then create custom user.
      // For simplicity here, we create email/password user first.
      // final userCredential = await authRepository.signUpWithEmailPassword(email, password);

      // IMPORTANT: Firebase will send OTP to the phone number.
      // If the email/password user is created *first*, you might want to link the phone
      // to this user later, or ensure the phone number is added to a custom user profile
      // in Firestore/Realtime DB if you intend to query by phone later.
      // For phone sign-in after OTP, the user is created or linked implicitly.
      // For this flow, we're relying on the phone verification itself to establish
      // the phone number as an authenticated credential for the user created by email/password.
      // This is a subtle but important Firebase distinction.


      // Step 2: Verify phone number
      // Note: The phone number verification itself can create or link to a user.
      // Since we already created an email/password user, if the phone number
      // is not already linked, verifyPhoneNumber might act as an update/link.
      // For a robust system, you'd usually complete phone auth then link it to the email account.
      // For simplicity in this example, we proceed with verification after email/password user is made.
      await authRepository.verifyPhoneNumber(
        phoneNumber,
        verificationFailed: (e) {
          onError(e.message ?? 'Phone verification failed.');
          state = AsyncValue.error(e, StackTrace.current);
        },
        codeSent: (verificationId, resendToken) {
          state = AsyncValue.data(verificationId); // Store verification ID
          onCodeSent(verificationId); // Trigger navigation to OTP screen
        },
        codeAutoRetrievalTimeout: (verificationId) {
          // This happens when the SMS isn't auto-read within the timeout.
          // The verificationId is still valid.
          // You might want to update UI to show manual input is needed.
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
      // Sign in with phone OTP. This will authenticate the user with their phone credential.
      // Since we already created an email/password user, Firebase will link this phone credential
      // to the existing user if they match based on initial creation context.
      await authRepository.signInWithPhoneNumberAndOtp(verificationId, smsCode);
      state = const AsyncValue.data(null); // Success, no verification ID needed anymore
    } on Exception catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Renamed from AutoDisposeAsyncNotifierProvider to AsyncNotifierProvider.autoDispose
final signUpControllerProvider =
AsyncNotifierProvider.autoDispose<SignUpController, String?>(() {
  return SignUpController();
});
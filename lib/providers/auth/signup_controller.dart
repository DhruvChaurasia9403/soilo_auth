// lib/features/auth/signup_controller.dart
import 'package:checking/features/auth/user_role.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/auth_repository.dart';

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
    state = const AsyncValue.loading();
    final authRepository = ref.read(authRepositoryProvider);

    // store pending values so we can complete signup after OTP verification
    _pendingFullName = fullName;
    _pendingPassword = password;
    _pendingPhone = phoneNumber;
    _pendingRole = role;

    try {
      await authRepository.verifyPhoneNumber(
        phoneNumber,
        verificationFailed: (e) {
          final errorMsg = e.message ?? 'Phone verification failed.';
          onError(errorMsg);
          state = AsyncValue.error(errorMsg, StackTrace.current);
        },
        codeSent: (verificationId, resendToken) {
          // store verificationId as state (OTP screen reads this)
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

  /// Step 2: after OTP entered — create Firebase user and link phone credential
  Future<void> completeSignUpWithOtp(String verificationId, String smsCode) async {
    state = const AsyncValue.loading();
    final authRepository = ref.read(authRepositoryProvider);
    final firebaseAuth = FirebaseAuth.instance;

    try {
      // Build phone credential from verificationId & smsCode (do NOT sign-in with this)
      final phoneCredential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Validate pending fields
      if (_pendingPhone == null ||
          _pendingPassword == null ||
          _pendingFullName == null ||
          _pendingRole == null) {
        throw Exception('Missing pending signup data.');
      }

      // 1) Create the email/password account (this signs in the new user)
      // Use repository helper which calls createUserWithEmailAndPassword
      final userCredential = await authRepository.signUpWithPhonePassword(
        _pendingPhone!,
        _pendingPassword!,
      );

      final user = userCredential.user;
      if (user == null) throw Exception('Failed to create user.');

      // 2) Link the phone credential to the newly created user
      await user.linkWithCredential(phoneCredential);

      // 3) Create Firestore profile
      await authRepository.createUserProfile(
        uid: user.uid,
        fullName: _pendingFullName!,
        phoneNumber: _pendingPhone!,
        role: _pendingRole!,
      );

      // clear pending values
      _pendingFullName = null;
      _pendingPassword = null;
      _pendingPhone = null;
      _pendingRole = null;

      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e) {
      // Return firebase-specific errors
      state = AsyncValue.error(e, StackTrace.current);
    } on Exception catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Provider (do NOT autoDispose to preserve pending data during OTP flow)
final signUpControllerProvider =
AsyncNotifierProvider<SignUpController, String?>(() {
  return SignUpController();
});

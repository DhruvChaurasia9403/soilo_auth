import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(FirebaseAuth.instance);
});

class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository(this._firebaseAuth);

  // Stream to listen to auth state changes (User logged in/out)
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // --- Email/Password & Phone Sign Up/Login ---

  Future<UserCredential> signUpWithEmailPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to sign up with email and password.');
    } catch (e) {
      throw Exception('An unexpected error occurred during email/password sign up.');
    }
  }

  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to sign in with email and password.');
    } catch (e) {
      throw Exception('An unexpected error occurred during email/password sign in.');
    }
  }

  // --- Phone OTP Verification ---
  // This method will initiate the phone verification process.
  // Firebase will send an SMS to the provided phone number.
  Future<String?> verifyPhoneNumber(String phoneNumber,
      {required Function(FirebaseAuthException e) verificationFailed,
        required Function(String verificationId, int? resendToken) codeSent,
        required Function(String smsCode) codeAutoRetrievalTimeout}) async {
    Completer<String?> verificationIdCompleter = Completer<String?>();

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // AUTO SIGN IN (Android only) - happens automatically if OTP is auto-read
        // In a real app, you might want to sign in the user here
        // await _firebaseAuth.signInWithCredential(credential);
        // print("verificationCompleted: Auto verified and signed in: ${credential.smsCode}");
      },
      verificationFailed: (FirebaseAuthException e) {
        verificationFailed(e);
        verificationIdCompleter.complete(null);
      },
      codeSent: (String verificationId, int? resendToken) {
        codeSent(verificationId, resendToken);
        verificationIdCompleter.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        codeAutoRetrievalTimeout(verificationId);
        // The verification ID is still valid even if timeout occurs
        verificationIdCompleter.complete(verificationId);
      },
      timeout: const Duration(seconds: 60), // OTP timeout
    );
    return verificationIdCompleter.future;
  }

  // To sign in using OTP (after getting verificationId and smsCode)
  Future<UserCredential> signInWithPhoneNumberAndOtp(String verificationId, String smsCode) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to sign in with phone OTP.');
    } catch (e) {
      throw Exception('An unexpected error occurred during phone OTP sign in.');
    }
  }


  // --- Password Reset ---
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to send password reset email.');
    } catch (e) {
      throw Exception('An unexpected error occurred while sending password reset email.');
    }
  }

  // --- Logout ---
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to sign out.');
    } catch (e) {
      throw Exception('An unexpected error occurred during sign out.');
    }
  }
}
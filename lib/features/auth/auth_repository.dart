import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_role.dart';

// --- Provider ---
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
  );
});

// --- Constants ---
const String kFirebaseEmailDomain = '@soilo.app';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository(this._firebaseAuth, this._firestore);

  // Stream to listen to auth state changes (User logged in/out)
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // --- Helpers ---
  String _emailFromPhone(String phoneNumber) {
    final sanitizedPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    return '$sanitizedPhone$kFirebaseEmailDomain';
  }

  // --- Phone + Password Auth ---

  Future<UserCredential> signUpWithPhonePassword(String phoneNumber, String password) async {
    try {
      final email = _emailFromPhone(phoneNumber);
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to sign up.');
    } catch (e) {
      throw Exception('An unexpected error occurred during sign up.');
    }
  }

  Future<UserCredential> signInWithPhonePassword(String phoneNumber, String password) async {
    try {
      final email = _emailFromPhone(phoneNumber);
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to sign in.');
    } catch (e) {
      throw Exception('An unexpected error occurred during sign in.');
    }
  }

  // --- Firestore Profile ---

  Future<void> createUserProfile({
    required String uid,
    required String fullName,
    required String phoneNumber,
    required UserRole role,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'role': role.name,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  // --- ⭐ START: MISSING METHODS (RE-ADDED) ---

  // --- Phone OTP Verification ---
  // This method will initiate the phone verification process.
  Future<void> verifyPhoneNumber(String phoneNumber,
      {required Function(FirebaseAuthException e) verificationFailed,
        required Function(String verificationId, int? resendToken) codeSent,
        required Function(String verificationId) codeAutoRetrievalTimeout}) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // This is for auto-retrieval, which we aren't focusing on
        // for this manual OTP flow.
      },
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 60), // OTP timeout
    );
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

  // --- ⭐ END: MISSING METHODS (RE-ADDED) ---


  // --- Password Reset ---
  Future<void> sendPasswordResetEmail(String phoneNumber) async {
    // Note: This method is no longer used, as the forgot password flow
    // now just sends an OTP. We could remove this, but it's fine
    // to leave for now.
    try {
      final email = _emailFromPhone(phoneNumber);
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to send password reset email.');
    } catch (e) {
      throw Exception('An unexpected error occurred while sending password reset email.');
    }
  }

  // --- Update Password ---
  Future<void> updateUserPassword(String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found.');
      }
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to update password.');
    } catch (e) {
      throw Exception('An unexpected error occurred while updating password.');
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
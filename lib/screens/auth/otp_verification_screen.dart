import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/signup_controller.dart';
import '../../features/auth/login_controller.dart';
import '../../features/auth/forgot_password_controller.dart';

// This enum must be in a place accessible by all auth screens
// We put it in signup_screen.dart, so we import it.
// Or, move it to its own file.
import 'signup_screen.dart' show VerificationPurpose;

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final VerificationPurpose purpose; // ⭐ ADDED

  const OtpVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    required this.purpose, // ⭐ ADDED
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _onVerifyPressed() {
    if (_formKey.currentState!.validate()) {
      final otp = _otpController.text.trim();
      switch (widget.purpose) {
        case VerificationPurpose.signUp:
          ref
              .read(signUpControllerProvider.notifier)
              .completeSignUpWithOtp(widget.verificationId, otp);
          break;
        case VerificationPurpose.login:
          ref
              .read(loginControllerProvider.notifier)
              .completeLoginWithOtp(widget.verificationId, otp);
          break;
        case VerificationPurpose.passwordReset:
          ref
              .read(forgotPasswordControllerProvider.notifier)
              .verifyOtpAndSignIn(widget.verificationId, otp);
          break;
      }
    }
  }

  // Helper to get the correct loading state
  bool _isLoading(WidgetRef ref) {
    switch (widget.purpose) {
      case VerificationPurpose.signUp:
        return ref.watch(signUpControllerProvider).isLoading;
      case VerificationPurpose.login:
        return ref.watch(loginControllerProvider).isLoading;
      case VerificationPurpose.passwordReset:
        return ref.watch(forgotPasswordControllerProvider).isLoading;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to all three controllers. Only one will be active.

    // 1. SignUpController listener
    ref.listen<AsyncValue<String?>>(
      signUpControllerProvider,
          (_, state) {
        if (widget.purpose != VerificationPurpose.signUp) return;
        if (state.hasError && !state.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error.toString())),
          );
        }
        if (state.hasValue && state.value == null) {
          // Success! GoRouter will handle the redirect to home.
        }
      },
    );

    // 2. LoginController listener
    ref.listen<AsyncValue<String?>>(
      loginControllerProvider,
          (_, state) {
        if (widget.purpose != VerificationPurpose.login) return;
        if (state.hasError && !state.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error.toString())),
          );
        }
        if (state.hasValue && state.value == null) {
          // Success! GoRouter will handle the redirect to home.
        }
      },
    );

    // 3. ForgotPasswordController listener
    ref.listen<AsyncValue<String?>>(
      forgotPasswordControllerProvider,
          (_, state) {
        if (widget.purpose != VerificationPurpose.passwordReset) return;
        if (state.hasError && !state.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error.toString())),
          );
        }
        if (state.hasValue && state.value == null) {
          // Success! User is signed in. Navigate to reset password.
          context.go('/reset-password');
        }
      },
    );

    final isLoading = _isLoading(ref);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Phone'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Verify Phone Number',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Enter the 6-digit code sent to ${widget.phoneNumber}',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 10),
                decoration: const InputDecoration(
                  labelText: 'OTP Code',
                  counterText: "", // Hide the default counter
                ),
                validator: (value) {
                  if (value == null || value.length != 6) {
                    return 'Please enter a 6-digit OTP.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _onVerifyPressed,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('VERIFY'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                  // TODO: Implement resend OTP logic
                  // This would need to call the correct controller
                  // e.g., ref.read(forgotPasswordControllerProvider.notifier).sendVerificationOtp(...)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Resending OTP...')),
                  );
                },
                child: const Text('Resend Code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
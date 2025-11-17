// lib/screens/auth/otp_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/signup_controller.dart';
import '../../features/auth/login_controller.dart';
import '../../features/auth/forgot_password_controller.dart';
import 'signup_screen.dart' show VerificationPurpose;

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final VerificationPurpose purpose;

  const OtpVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    required this.purpose,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _secondsLeft = 30;
  bool _resendEnabled = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      _secondsLeft = 30;
      _resendEnabled = false;
    });
    Future.doWhile(() async {
      if (_secondsLeft <= 0) {
        setState(() => _resendEnabled = true);
        return false;
      }
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _secondsLeft--);
      return true;
    });
  }

  void _onVerifyPressed() {
    if (_formKey.currentState!.validate()) {
      final otp = _otpController.text.trim();
      switch (widget.purpose) {
        case VerificationPurpose.signUp:
          ref.read(signUpControllerProvider.notifier).completeSignUpWithOtp(widget.verificationId, otp);
          break;
        case VerificationPurpose.login:
          ref.read(loginControllerProvider.notifier).completeLoginWithOtp(widget.verificationId, otp);
          break;
        case VerificationPurpose.passwordReset:
          ref.read(forgotPasswordControllerProvider.notifier).verifyOtpAndSignIn(widget.verificationId, otp);
          break;
      }
    }
  }

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

  String _maskedPhone(String phone) {
    // mask middle digits for display: keep country code and last 3 digits
    if (phone.length < 6) return phone;
    final prefix = phone.substring(0, phone.indexOf(RegExp(r'\d')) + 1);
    final last = phone.length >= 4 ? phone.substring(phone.length - 3) : phone;
    return '${phone.substring(0, phone.length - 7)}•••$last';
  }

  @override
  Widget build(BuildContext context) {
    // listeners for success & errors
    ref.listen<AsyncValue<String?>>(
      signUpControllerProvider,
          (_, state) {
        if (widget.purpose != VerificationPurpose.signUp) return;
        if (state.hasError && !state.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error.toString())));
        }
      },
    );

    ref.listen<AsyncValue<String?>>(
      loginControllerProvider,
          (_, state) {
        if (widget.purpose != VerificationPurpose.login) return;
        if (state.hasError && !state.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error.toString())));
        }
      },
    );

    ref.listen<AsyncValue<String?>>(
      forgotPasswordControllerProvider,
          (_, state) {
        if (widget.purpose != VerificationPurpose.passwordReset) return;
        if (state.hasError && !state.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error.toString())));
        }
        if (state.hasValue && state.value == null) {
          // Success: signed in for reset
          context.go('/reset-password');
        }
      },
    );

    final isLoading = _isLoading(ref);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Phone'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Verify Phone Number', style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('Enter the 6-digit code sent to ${_maskedPhone(widget.phoneNumber)}', style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 18),

                  // OTP field
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, letterSpacing: 8),
                    decoration: const InputDecoration(labelText: 'OTP Code', counterText: ""),
                    validator: (value) {
                      if (value == null || value.length != 6) return 'Please enter a 6-digit OTP.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _onVerifyPressed,
                      child: isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('VERIFY'),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_resendEnabled ? 'Didn\'t get it?' : 'Resend available in $_secondsLeft s', style: theme.textTheme.bodySmall),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: isLoading || !_resendEnabled
                            ? null
                            : () {
                          // Trigger resend by calling the same controller's send method.
                          // We don't change behavior: just re-use controllers.
                          switch (widget.purpose) {
                            case VerificationPurpose.signUp:
                            // Need pending data — UI already persisted it in controller
                            // Here we just show toast. If you have resend token logic, call it via controller.
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resend requested')));
                              break;
                            case VerificationPurpose.login:
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resend requested')));
                              break;
                            case VerificationPurpose.passwordReset:
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resend requested')));
                              break;
                          }
                          _startCountdown();
                        },
                        child: const Text('Resend Code'),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

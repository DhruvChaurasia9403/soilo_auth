import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth/signup_controller.dart';
import '../../providers/auth/login_controller.dart';
import '../../providers/auth/forgot_password_controller.dart';
import '../../themes/app_factory.dart';
import 'signup_screen.dart' show VerificationPurpose;
import '../../features/auth/user_role.dart'; // Import UserRole for redirection logic

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final VerificationPurpose purpose;
  final String? password; // 👈 Added password field

  const OtpVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    required this.purpose,
    this.password, // 👈 Accept it in constructor
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String _currentVerificationId;
  int _secondsLeft = 30;
  bool _resendEnabled = false;

  @override
  void initState() {
    super.initState();
    _currentVerificationId = widget.verificationId;
    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      _secondsLeft = 30;
      _resendEnabled = false;
    });
    Future.doWhile(() async {
      if (!mounted) return false;
      if (_secondsLeft <= 0) {
        setState(() => _resendEnabled = true);
        return false;
      }
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => _secondsLeft--);
      }
      return true;
    });
  }

  void _onVerifyPressed() {
    if (_formKey.currentState!.validate()) {
      final otp = _otpController.text.trim();
      switch (widget.purpose) {
        case VerificationPurpose.signUp:
          ref
              .read(signUpControllerProvider.notifier)
              .completeSignUpWithOtp(_currentVerificationId, otp);
          break;

        case VerificationPurpose.login:
        // 👈 USE THE PASSWORD HERE FOR FINAL LOGIN
          if (widget.password != null) {
            ref
                .read(loginControllerProvider.notifier)
                .completeLoginWithOtp(
                verificationId: _currentVerificationId,
                smsCode: otp,
                password: widget.password!
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error: Password missing for final login.'))
            );
          }
          break;

        case VerificationPurpose.passwordReset:
          ref
              .read(forgotPasswordControllerProvider.notifier)
              .verifyOtpAndSignIn(_currentVerificationId, otp);
          break;
      }
    }
  }

  Future<void> _onResendPressed() async {
    // Disable button immediately to prevent double clicks
    setState(() {
      _resendEnabled = false;
      _secondsLeft = 30; // Reset visual timer immediately
    });
    _startCountdown();

    // Helper to handle success
    void handleSuccess(String newVerId) {
      if (!mounted) return;
      setState(() => _currentVerificationId = newVerId);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Code resent successfully!')));
      // _startCountdown(); // 👈 Start timer ONLY after success
    }
    // 👇 New Handler for Timeout
    void handleTimeout(String newVerId) {
      if (!mounted) return;
      setState(() => _currentVerificationId = newVerId);
      // Show a different message so user knows what happened
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Auto-retrieval timed out. Please enter code manually.')));
      // ✅ Re-enable timer/button so they aren't stuck
      // _startCountdown();
    }

    // Helper to handle error
    void handleError(String err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Resend failed: $err')));
      // _startCountdown(); // 👈 Start timer even on error so user can try again later
    }

    try {
      switch (widget.purpose) {
        case VerificationPurpose.signUp:
          await ref.read(signUpControllerProvider.notifier).resendOtp(
            onCodeSent: handleSuccess,
            onError: handleError,
          );
          break;

        case VerificationPurpose.login:
          await ref.read(loginControllerProvider.notifier).resendOtp(
            onCodeSent: handleSuccess,
            onError: handleError,
            onAutoRetrievalTimeout: handleTimeout,
          );
          break;

        case VerificationPurpose.passwordReset:
          await ref
              .read(forgotPasswordControllerProvider.notifier)
              .sendVerificationOtp(
            phoneNumber: widget.phoneNumber,
            onCodeSent: handleSuccess,
            onError: handleError,
            onAutoRetrievalTimeout: handleTimeout,
          );
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Resend error: $e')));
        // If immediate crash, re-enable button or start timer
        setState(() => _resendEnabled = true);
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
    if (phone.length < 6) return phone;
    final last = phone.length >= 4 ? phone.substring(phone.length - 4) : phone;
    return '...$last';
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<String?>>(
      signUpControllerProvider,
          (_, state) {
        if (widget.purpose != VerificationPurpose.signUp) return;
        if (state.hasError && !state.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error.toString())));
        }

        // NEW: Handle redirection based on state value after successful farmer sign up
        if (state.hasValue && state.value != null && !state.isLoading) {
          final parts = state.value!.split('|');
          if (parts[0] == 'onboarding') {
            final fullName = parts[1];
            final roleName = parts[2];
            final role = UserRole.values.firstWhere((r) => r.name == roleName);

            context.go('/onboarding', extra: {
              'fullName': fullName,
              'role': role,
            });
          }
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
          context.go('/reset-password');
        }
      },
    );

    final isLoading = _isLoading(ref);
    final theme = Theme.of(context);
    final themeConfig = Theme.of(context).extension<ThemeConfig>()!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [themeConfig.gradientStart, themeConfig.gradientEnd],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.phonelink_lock,
                  size: 44,
                  color: theme.primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'OTP Verification',
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the code sent to number ending in \n${_maskedPhone(widget.phoneNumber)}',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: 24,
                          letterSpacing: 12,
                          color: themeConfig.textColor,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Enter Code',
                          counterText: "",
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                          fillColor: themeConfig.inputFillColor,
                        ),
                        validator: (value) {
                          if (value == null || value.length != 6) {
                            return 'Enter 6-digit code';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _onVerifyPressed,
                          child: isLoading
                              ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                              : const Text('VERIFY'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _resendEnabled
                          ? 'Didn\'t receive code?'
                          : 'Resend in 00:${_secondsLeft.toString().padLeft(2, '0')}',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: isLoading || !_resendEnabled
                          ? null
                          : _onResendPressed,
                      child: Text(
                        'Resend',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: _resendEnabled
                              ? theme.primaryColor
                              : Colors.grey,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ).animate().fadeIn(duration: 500.ms),
          ),
        ),
      ),
    );
  }
}
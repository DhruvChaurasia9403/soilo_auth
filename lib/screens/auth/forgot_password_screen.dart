import 'package:checking/screens/auth/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Required for animations
import 'package:go_router/go_router.dart';
import '../../features/common/phone_input_field.dart';
import '../../features/common/primary_button.dart';
import '../../providers/auth/forgot_password_controller.dart';
import '../../themes/app_factory.dart'; // For ThemeConfig

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<String?>>(
      forgotPasswordControllerProvider,
          (_, state) {
        if (state.hasError && !state.isLoading) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.error.toString())));
        }
      },
    );

    final resetPasswordState = ref.watch(forgotPasswordControllerProvider);
    final theme = Theme.of(context);
    // Get the custom config from the theme extension
    final themeConfig = Theme.of(context).extension<ThemeConfig>()!;

    return Scaffold(
      // Extend body so gradient covers the top status bar area
      extendBodyBehindAppBar: true,
      appBar: AppBar(), // Uses factory theme (transparent, auto back button)
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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- Header Icon ---
                  Icon(
                    Icons.lock_open_outlined, // Indicates "unlocking" account
                    size: 44,
                    color: themeConfig.primaryColor,
                  ),
                  const SizedBox(height: 16),

                  // --- Headings ---
                  Text(
                    'Forgot Password?',
                    style: theme.textTheme.headlineMedium!.copyWith(fontSize: 23),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your registered phone number to receive a verification code.',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // --- Form ---
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PhoneInputField(
                          controller: _phoneController,
                        ),
                        const SizedBox(height: 24),

                    PrimaryButton(
                      text: 'SEND VERIFICATION CODE',
                      isLoading: resetPasswordState.isLoading,
                      onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                ref
                                    .read(forgotPasswordControllerProvider
                                    .notifier)
                                    .sendVerificationOtp(
                                  phoneNumber:
                                  _phoneController.text.trim(),
                                  onCodeSent: (verificationId) {
                                    context.push(
                                      '/otp-verification',
                                      extra: {
                                        'verificationId':
                                        verificationId,
                                        'phoneNumber':
                                        _phoneController.text
                                            .trim(),
                                        'purpose': VerificationPurpose
                                            .passwordReset,
                                      },
                                    );
                                  },
                                  onError: (error) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                        content:
                                        Text('Error: $error')));
                                  },
                                  onAutoRetrievalTimeout: null,
                                );
                              }
                            },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- Footer Text ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'You will be temporarily signed in to reset your password after verifying the code.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        // Ensure text is legible on both light/dark backgrounds
                        color: themeConfig.textColor.withAlpha(200),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 500.ms).slideY(
                begin: 0.1,
                end: 0,
                curve: Curves.easeOut,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
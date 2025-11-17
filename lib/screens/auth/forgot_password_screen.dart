// lib/screens/auth/forgot_password_screen.dart
import 'package:checking/screens/auth/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/forgot_password_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error.toString())));
        }
      },
    );

    final resetPasswordState = ref.watch(forgotPasswordControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
        child: Column(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Forgot Your Password?', style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text('Enter your registered phone number to receive a verification code.', style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
                      const SizedBox(height: 18),

                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Phone Number (e.g., +15551234567)', prefixIcon: Icon(Icons.phone)),
                        validator: (value) {
                          if (value == null || value.isEmpty || !value.startsWith('+') || value.length < 10) {
                            return 'Please enter a valid phone number with country code.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: resetPasswordState.isLoading
                              ? null
                              : () {
                            if (_formKey.currentState!.validate()) {
                              ref.read(forgotPasswordControllerProvider.notifier).sendVerificationOtp(
                                phoneNumber: _phoneController.text.trim(),
                                onCodeSent: (verificationId) {
                                  context.push('/otp-verification', extra: {
                                    'verificationId': verificationId,
                                    'phoneNumber': _phoneController.text.trim(),
                                    'purpose': VerificationPurpose.passwordReset,
                                  });
                                },
                                onError: (error) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
                                },
                              );
                            }
                          },
                          child: resetPasswordState.isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('SEND VERIFICATION CODE'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('You will be temporarily signed in to reset your password after verifying the code.', style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

import 'package:checking/screens/auth/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/forgot_password_controller.dart';

// Converted to ConsumerStatefulWidget to manage the controller
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error.toString())),
          );
        }
      },
    );

    final resetPasswordState = ref.watch(forgotPasswordControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
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
                'Forgot Your Password?',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Enter your registered phone number below to receive a verification code.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Phone Text Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number (e.g., +15551234567)',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      !value.startsWith('+') ||
                      value.length < 10) {
                    return 'Please enter a valid phone number with country code.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Send Button
              ElevatedButton(
                onPressed: resetPasswordState.isLoading
                    ? null
                    : () {
                  if (_formKey.currentState!.validate()) {
                    ref
                        .read(forgotPasswordControllerProvider.notifier)
                        .sendVerificationOtp(
                      phoneNumber: _phoneController.text.trim(),
                      onCodeSent: (verificationId) {
                        context.push(
                          '/otp-verification',
                          extra: {
                            'verificationId': verificationId,
                            'phoneNumber': _phoneController.text.trim(),
                            'purpose': VerificationPurpose.passwordReset,
                          },
                        );
                      },
                      onError: (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $error')),
                        );
                      },
                    );
                  }
                },
                child: resetPasswordState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('SEND VERIFICATION CODE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/signup_controller.dart';
import '../home/home_screen.dart'; // Navigate to home on success

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String verificationId;
  final String phoneNumber; // Optional, for display

  const OtpVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Listen for state changes in the SignUpController
    ref.listen<AsyncValue<String?>>(
      signUpControllerProvider,
          (_, state) {
        if (state.hasError && !state.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error.toString())),
          );
        }
        if (state.hasValue && state.value == null) {
          // If state.value is null, it means OTP verification was successful
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Phone number verified!')),
          );
          // Navigate to home screen and remove all previous routes
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
                (Route<dynamic> route) => false,
          );
        }
      },
    );

    final signUpState = ref.watch(signUpControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Phone'),
        // REMOVED: backgroundColor: Colors.green.shade800,
        // This is now handled by AppBarTheme
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
                // UPDATED: Using headlineMedium for consistency with other screens
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Enter the 6-digit code sent to ${widget.phoneNumber}',
                // This was already correct!
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                // This style is specific to the OTP field and is fine
                style: const TextStyle(fontSize: 24, letterSpacing: 10),
                decoration: const InputDecoration(
                  labelText: 'OTP Code',
                  // REMOVED: border: OutlineInputBorder(),
                  // This is now handled by InputDecorationTheme
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
                onPressed: signUpState.isLoading
                    ? null
                    : () {
                  if (_formKey.currentState!.validate()) {
                    ref
                        .read(signUpControllerProvider.notifier)
                        .completeSignUpWithOtp(
                      widget.verificationId,
                      _otpController.text.trim(),
                    );
                  }
                },
                // REMOVED: style: ElevatedButton.styleFrom(...)
                // This is now handled by ElevatedButtonTheme
                child: signUpState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'VERIFY',
                  // REMOVED: style: TextStyle(...)
                  // This is now handled by the textStyle in ElevatedButtonTheme
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: signUpState.isLoading
                    ? null
                    : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Resending OTP...')),
                  );
                  // TODO: Implement resend OTP logic
                },
                // This child will be styled correctly by TextButtonTheme
                child: const Text('Resend Code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../features/common/password_input_field.dart';
import '../../features/common/phone_input_field.dart';
import '../../providers/auth/signup_controller.dart';
import '../../features/auth/user_role.dart';
import '../../features/utils/validators.dart';
import '../../themes/app_factory.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  UserRole? _selectedRole;

  // 1. State for toggles
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signUpState = ref.watch(signUpControllerProvider);
    final theme = Theme.of(context);
    final themeConfig = Theme.of(context).extension<ThemeConfig>()!;

    return Scaffold(
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
                  Icon(
                    Icons.person_add_outlined,
                    size: 64,
                    color: themeConfig.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Create Account',
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join our community today',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Full Name
                        TextFormField(
                          controller: _fullNameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Please enter your full name.'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // Phone
                        PhoneInputField(
                          controller: _phoneController,
                        ),
                        const SizedBox(height: 16),

                        // Role Dropdown
                        DropdownButtonFormField<UserRole>(
                          value: _selectedRole,
                          hint: const Text('Select Your Role'),
                          decoration: const InputDecoration(
                            labelText: 'Role',
                            prefixIcon: Icon(Icons.work_outline),
                          ),
                          items: UserRole.values.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role.displayName),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => _selectedRole = value),
                          validator: (value) =>
                          value == null ? 'Please select a role.' : null,
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        PasswordInputField(
                          controller: _passwordController,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password Field
                        PasswordInputField(
                          controller: _confirmPasswordController,
                          labelText: 'Confirm Password',
                          textInputAction: TextInputAction.done,
                          // Override the default validator to check matching
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // Sign Up Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: signUpState.isLoading
                                ? null
                                : () {
                              if (_formKey.currentState!.validate()) {
                                ref
                                    .read(signUpControllerProvider
                                    .notifier)
                                    .signUpAndVerifyPhone(
                                  fullName: _fullNameController.text
                                      .trim(),
                                  password: _passwordController.text
                                      .trim(),
                                  phoneNumber: _phoneController.text
                                      .trim(),
                                  role: _selectedRole!,
                                  onCodeSent: (verificationId) {
                                    context.push(
                                      '/otp-verification',
                                      extra: {
                                        'verificationId':
                                        verificationId,
                                        'phoneNumber':
                                        _phoneController.text
                                            .trim(),
                                        'purpose':
                                        VerificationPurpose
                                            .signUp,
                                      },
                                    );
                                  },
                                  onError: (error) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                        content: Text(
                                            'Signup Error: $error')));
                                  },
                                );
                              }
                            },
                            child: signUpState.isLoading
                                ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                // 2. REMOVED: Colors.white
                                // 2. FIXED: Uses onPrimary (contrast color from theme)
                                color: theme.colorScheme.onPrimary,
                                strokeWidth: 2.5,
                              ),
                            )
                                : const Text('SIGN UP'),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account?',
                              style: theme.textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: () => context.pop(),
                              child: const Text('Login'),
                            ),
                          ],
                        ),
                      ]
                          .animate(interval: 50.ms)
                          .slideY(begin: 0.2, end: 0, curve: Curves.easeOut)
                          .fadeIn(),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 500.ms),
            ),
          ),
        ),
      ),
    );
  }
}

enum VerificationPurpose {
  signUp,
  login,
  passwordReset,
}
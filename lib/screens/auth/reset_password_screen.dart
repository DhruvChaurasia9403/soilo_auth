import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Required for animations
import '../../features/common/password_input_field.dart';
import '../../features/common/primary_button.dart';
import '../../providers/auth/auth_controller.dart';
import '../../features/utils/validators.dart';
import '../../providers/auth/reset_password_controller.dart';
import '../../themes/app_factory.dart'; // For ThemeConfig

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State for visibility toggles
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showPasswordRules() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Password Rules'),
        content: Text(AppValidators.passwordRules),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(
      resetPasswordControllerProvider,
          (_, state) async {
        // 1. Ignore Loading State (Prevents premature firing)
        if (state.isLoading) return;
        // 2. HANDLE ERROR FIRST
        if (state.hasError) {
          final error = state.error.toString();
          // Check for session expiration
          if (error.toLowerCase().contains('no user') ||
              error.toLowerCase().contains('unauthenticated')) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Session expired. Please verify OTP again.'))
            );
            context.go('/forgot-password');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
          }
          // 🛑 RETURN HERE so we don't fall through to success logic
          return;
        }
        // 3. HANDLE SUCCESS (Only if no error)
        // We use 'valueOrNull' check to ensure we actually completed the action
        if (!state.hasError && state.hasValue) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Password reset successfully. Please log in.')));
          // context.go('/login');
        }
      },
    );

    final resetState = ref.watch(resetPasswordControllerProvider);
    final theme = Theme.of(context);
    // Get custom theme config
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
                  // --- Header Icon ---
                  Icon(
                    Icons.lock_reset,
                    size: 44,
                    color: themeConfig.primaryColor,
                  ),
                  const SizedBox(height: 16),

                  // --- Headings ---
                  Text(
                    'Reset Password',
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a new, strong password for your account.',
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
                        // New Password Field
                        PasswordInputField(
                          controller: _newPasswordController,
                          labelText: 'New Password',
                        ),

                        // Helper button for Password Rules (Moved out of suffixIcon)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _showPasswordRules,
                            icon: const Icon(Icons.info_outline, size: 16),
                            label: const Text('Password Rules'),
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Confirm Password Field
                        PasswordInputField(
                          controller: _confirmPasswordController,
                          labelText: 'Confirm Password',
                          textInputAction: TextInputAction.done,
                          // Override the default validator to check matching
                          validator: (value) {
                            if (value != _newPasswordController.text) {
                              return 'Passwords do not match.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // Reset Button
                        PrimaryButton(
                          text: 'RESET PASSWORD',
                          isLoading: resetState.isLoading,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              ref
                                  .read(resetPasswordControllerProvider.notifier)
                                  .updateUserPassword(_newPasswordController.text.trim());
                            }
                          },
                        ),
                      ],
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
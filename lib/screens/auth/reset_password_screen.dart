import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Required for animations
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
          (_, state) {
        if (state.hasError && !state.isLoading) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.error.toString())));
        }
        if (state.hasValue) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Password reset successfully. Please log in.')));
          // For security, log the user out and send to login
          ref.read(authControllerProvider.notifier).signOut();
          context.go('/login');
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
                        TextFormField(
                          controller: _newPasswordController,
                          obscureText: _obscureNewPassword,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNewPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(() =>
                              _obscureNewPassword = !_obscureNewPassword),
                            ),
                          ),
                          validator: AppValidators.validatePassword,
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
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirm New Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: theme.hintColor,
                              ),
                              onPressed: () => setState(() =>
                              _obscureConfirmPassword =
                              !_obscureConfirmPassword),
                            ),
                          ),
                          validator: (value) {
                            if (value != _newPasswordController.text) {
                              return 'Passwords do not match.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // Reset Button
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: resetState.isLoading
                                ? null
                                : () {
                              if (_formKey.currentState!.validate()) {
                                ref
                                    .read(resetPasswordControllerProvider
                                    .notifier)
                                    .updateUserPassword(
                                    _newPasswordController.text
                                        .trim());
                              }
                            },
                            child: resetState.isLoading
                                ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                // Use onPrimary so it works with any button color
                                color: theme.colorScheme.onPrimary,
                                strokeWidth: 2.5,
                              ),
                            )
                                : const Text('RESET PASSWORD'),
                          ),
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
// lib/screens/auth/reset_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/reset_password_controller.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/utils/validators.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

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
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error.toString())));
        }
        if (state.hasValue) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset successfully. Please log in.')));
          // For security, log the user out and send to login
          ref.read(authControllerProvider.notifier).signOut();
          context.go('/login');
        }
      },
    );

    final resetState = ref.watch(resetPasswordControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create New Password'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text('Create New Password', style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('Your new password must be different from previously used passwords.', style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
                const SizedBox(height: 18),

                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(icon: const Icon(Icons.info_outline), onPressed: _showPasswordRules),
                  ),
                  validator: AppValidators.validatePassword,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirm New Password', prefixIcon: Icon(Icons.lock_outline)),
                  validator: (value) {
                    if (value != _newPasswordController.text) return 'Passwords do not match.';
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: resetState.isLoading
                        ? null
                        : () {
                      if (_formKey.currentState!.validate()) {
                        ref.read(resetPasswordControllerProvider.notifier).updateUserPassword(_newPasswordController.text.trim());
                      }
                    },
                    child: resetState.isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('RESET PASSWORD'),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

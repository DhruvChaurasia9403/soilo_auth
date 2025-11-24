import 'package:flutter/material.dart';

import '../auth/utils/validators.dart';

class PasswordInputField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator; // Allow custom validator override

  const PasswordInputField({
    super.key,
    required this.controller,
    this.labelText = 'Password',
    this.hintText,
    this.textInputAction = TextInputAction.done,
    this.validator,
  });

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  // Internal state to handle visibility toggling
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      textInputAction: widget.textInputAction,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            // Use theme.hintColor or your specific ThemeConfig color here
            color: theme.hintColor,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      // Use the passed validator, OR fall back to the default password validator
      validator: widget.validator ?? AppValidators.validatePassword,
    );
  }
}
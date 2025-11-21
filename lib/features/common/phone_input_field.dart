import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final bool enabled;
  final TextInputAction textInputAction;
  final Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;

  const PhoneInputField({
    super.key,
    required this.controller,
    this.labelText = 'Phone Number',
    this.hintText = 'e.g., +15551234567',
    this.enabled = true,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.phone,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,

      // 👇 Standardized Input Formatters
      inputFormatters: [
        // Limit to 13 chars (e.g. +1 555 555 5555)
        LengthLimitingTextInputFormatter(13),
        // Only allow digits and the '+' symbol
        FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
      ],

      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: const Icon(Icons.phone_outlined),
        // The rest of the styling (borders, fill) comes automatically
        // from your AppTheme / ThemeFactory!
      ),

      // 👇 Default validator if none provided
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return 'Phone number is required';
        }
        if (!value.startsWith('+')) {
          return 'Must start with + (Country Code)';
        }
        if (value.length < 10) {
          return 'Enter a valid phone number';
        }
        return null;
      },
    );
  }
}
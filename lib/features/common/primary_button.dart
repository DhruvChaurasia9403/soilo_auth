import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity, // Ensures full width
      // Height is handled by ElevatedButtonTheme in app_factory.dart
      child: ElevatedButton(
        // If loading, disable the button (null) so it can't be clicked again
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            // Use onPrimary to ensure contrast against the button color
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        )
            : Text(text),
      ),
    );
  }
}
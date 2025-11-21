class AppValidators {
  static final RegExp _passwordRegExp = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+={}\[\]:;"<>,.?~\\-]).{8,}$',
  );

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    if (!_passwordRegExp.hasMatch(value)) {
      return 'Must contain: 1 uppercase, 1 lowercase, 1 number, 1 special char.';
    }
    return null;
  }

  static String get passwordRules =>
      'Password must be at least 8 characters long and contain at least one of each:\n'
          '• An uppercase letter (A-Z)\n'
          '• A lowercase letter (a-z)\n'
          '• A number (0-9)\n'
          '• A special character (e.g., !, @, #, \$)';
}
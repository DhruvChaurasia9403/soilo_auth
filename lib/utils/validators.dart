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
}
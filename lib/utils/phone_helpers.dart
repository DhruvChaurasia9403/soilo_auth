// lib/utils/phone_helpers.dart

// Masks a phone number, showing only the last 4 digits.
String maskedPhone(String phone) {
  if (phone.length < 6) return phone;
  final last = phone.length >= 4 ? phone.substring(phone.length - 4) : phone;
  return '...$last';
}
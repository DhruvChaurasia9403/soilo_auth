// lib/features/onboarding/data/models/farm_detail_model.dart
import 'package:checking/features/auth/user_role.dart';

class FarmDetailModel {
  // Page 1 data
  final String? fullName;
  final UserRole? role;

  // Page 2 data (can have multiple crops)
  final List<CropEntry> cropEntries;

  // Page 3 data
  final double? farmSizeHectares;
  final String? farmLocation; // GPS string

  FarmDetailModel({
    this.fullName,
    this.role,
    this.cropEntries = const [],
    this.farmSizeHectares,
    this.farmLocation,
  });

  FarmDetailModel copyWith({
    String? fullName,
    UserRole? role,
    List<CropEntry>? cropEntries,
    double? farmSizeHectares,
    String? farmLocation,
  }) {
    return FarmDetailModel(
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      cropEntries: cropEntries ?? this.cropEntries,
      farmSizeHectares: farmSizeHectares ?? this.farmSizeHectares,
      farmLocation: farmLocation ?? this.farmLocation,
    );
  }
}

class CropEntry {
  final String cropType;
  final DateTime dateSown; // Use DateTime for Flutter logic

  CropEntry({
    required this.cropType,
    required this.dateSown,
  });

  String get dateSownFormatted =>
      '${dateSown.year}-${dateSown.month.toString().padLeft(2, '0')}-${dateSown.day.toString().padLeft(2, '0')}';
}
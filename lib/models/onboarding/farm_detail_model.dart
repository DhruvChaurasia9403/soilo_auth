// lib/features/onboarding/data/models/farm_detail_model.dart
import 'package:checking/models/auth/user_role.dart';

// --- Main Model ---
class FarmDetailModel {
  // Page 1 data
  final String? fullName;
  final UserRole? role;
  final String? language; // NEW: Language selection

  // Page 2 data (list of farms/crops)
  final List<FarmEntry> farmEntries;

  FarmDetailModel({
    this.fullName,
    this.role,
    this.language, // NEW
    this.farmEntries = const [],
  });

  FarmDetailModel copyWith({
    String? fullName,
    UserRole? role,
    String? language, // NEW
    List<FarmEntry>? farmEntries,
  }) {
    return FarmDetailModel(
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      language: language ?? this.language, // NEW
      farmEntries: farmEntries ?? this.farmEntries,
    );
  }
}
// --- Farm Entry Model ---
class FarmEntry {
  // Farm Details
  double? farmSizeHectares;
  String? farmLocation; // GPS string or name

  // Crop Details
  String cropType;
  DateTime dateSown; // Use DateTime for Flutter logic

  FarmEntry({
    this.farmSizeHectares,
    this.farmLocation,
    required this.cropType,
    required this.dateSown,
  });

  String get dateSownFormatted =>
      '${dateSown.year}-${dateSown.month.toString().padLeft(2, '0')}-${dateSown.day.toString().padLeft(2, '0')}';
}
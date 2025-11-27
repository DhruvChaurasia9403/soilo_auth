// lib/providers/farmer_onboarding_controller.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth/auth_repository.dart';
import '../../models/auth/user_role.dart';
import '../../models/onboarding/farm_detail_model.dart';
import '../../services/api/soilo_api_service.dart';
import '../../services/location/location_service.dart';
import '../../routes/router.dart';

class FarmerOnboardingController extends AsyncNotifier<FarmDetailModel> {
  // Use a full model for state to easily update fields
  @override
  FarmDetailModel build() {
    return FarmDetailModel(); // Initial empty model
  }

  // --- Step 1: Initialization ---
  void initializeProfile({
    required String fullName,
    required UserRole role,
    required String language,
  }) {
    state = AsyncValue.data(
      state.value!.copyWith(
        fullName: fullName,
        role: role,
        language: language,
      ),
    );
  }

  // --- Step 2: Farm & Crops ---
  void updateFarmEntries(List<FarmEntry> entries) {
    state = AsyncValue.data(
      state.value!.copyWith(farmEntries: entries),
    );
  }

  // --- Location Helper (Used by Page 2 for specific FarmEntry) ---
  Future<String> requestLocation(Function(String error) onError) async {
    final locationService = ref.read(locationServiceProvider);
    try {
      // Note: We don't use the main state's loading here, as it would block the whole page.
      final locationString = await locationService.getCurrentLocation();
      return locationString;
    } catch (e) {
      onError(e.toString());
      // Return a temporary error message instead of throwing
      return "Error: ${e.toString()}";
    }
  }

  // --- Final Submit ---
  Future<void> submitOnboarding(Function() onSuccess, Function(String) onError) async {
    state = const AsyncValue.loading();
    final model = state.value;

    if (model == null || model.farmEntries.isEmpty || model.farmEntries.any((e) => e.farmLocation == null || e.farmSizeHectares == null)) {
      onError("Missing mandatory farm or crop details.");
      state = AsyncValue.error("Missing mandatory data.", StackTrace.current);
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("User session not found. Please login again.");
      }

      // 3. Persist data to Firestore (Assuming an updated method in AuthRepository)
      final authRepo = ref.read(authRepositoryProvider);

      // We'll assume AuthRepository has a method to update the full farmer profile now
      // This is a placeholder structure:
      await authRepo.updateFarmerProfile(
        uid: user.uid,
        language: model.language!,
        farmEntries: model.farmEntries,
      );

      // Assume success for now
      ref.read(shouldShowOnboardingProvider.notifier).state = false;
      state = AsyncValue.data(model);
      onSuccess();
    } catch (e) {
      onError('Submission failed: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final farmerOnboardingControllerProvider =
AsyncNotifierProvider<FarmerOnboardingController, FarmDetailModel>(() {
  return FarmerOnboardingController();
});


// --- Crop Options Provider ---
/*
final cropOptionsProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final apiService = ref.read(soiloApiServiceProvider);
  return apiService.fetchCropOptions();
});
*/


// Provides the list of crops from the API (Memoized)
final cropOptionsProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  // Using hardcoded list for now as per the user's current setup in the previous file.
  await Future.delayed(const Duration(milliseconds: 300));
  return const [
    'Wheat', 'Rice', 'Maize (Corn)', 'Cotton', 'Sugarcane',
    'Soybean', 'Groundnut', 'Mustard', 'Potato', 'Tomato',
    'Onion', 'Barley', 'Millet', 'Sunflower', 'Chickpea (Gram)',
  ];
});
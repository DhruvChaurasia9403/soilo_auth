// lib/providers/farmer_onboarding_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/user_role.dart';
import '../features/onboarding/data/models/farm_detail_model.dart';
import '../services/api/soilo_api_service.dart';
import '../services/location/location_service.dart';

class FarmerOnboardingController extends AsyncNotifier<FarmDetailModel> {
  // Use a full model for state to easily update fields
  @override
  FarmDetailModel build() {
    return FarmDetailModel(); // Initial empty model
  }

  // --- Step 1: Initialization ---
  void initializeProfile(String fullName, UserRole role) {
    state = AsyncValue.data(
      state.value!.copyWith(fullName: fullName, role: role),
    );
  }

  // --- Step 2: Crops ---
  void updateCropEntries(List<CropEntry> entries) {
    state = AsyncValue.data(
      state.value!.copyWith(cropEntries: entries),
    );
  }

  // --- Step 3: Farm Details & Location ---
  Future<void> requestLocation(Function(String error) onError) async {
    final locationService = ref.read(locationServiceProvider);
    try {
      state = AsyncValue.loading();
      final locationString = await locationService.getCurrentLocation();
      state = AsyncValue.data(
        state.value!.copyWith(farmLocation: locationString),
      );
    } catch (e) {
      onError(e.toString());
      state = AsyncValue.data(state.value!); // Revert to data state on error
    }
  }

  void updateFarmDetails(double farmSize, String farmLocation) {
    state = AsyncValue.data(
      state.value!.copyWith(
        farmSizeHectares: farmSize,
        farmLocation: farmLocation,
      ),
    );
  }

  // --- Final Submit ---
  Future<void> submitOnboarding(Function() onSuccess, Function(String) onError) async {
    state = const AsyncValue.loading();
    final model = state.value;

    if (model == null || model.farmLocation == null || model.farmSizeHectares == null) {
      onError("Missing mandatory farm details.");
      state = AsyncValue.error("Missing mandatory data.", StackTrace.current);
      return;
    }

    try {
      // 1. Persist data to Firestore (Example placeholder)
      // Since this data is part of the user profile, you would typically
      // update the 'users' collection with this new information.

      // final authRepo = ref.read(authRepositoryProvider);
      // await authRepo.updateFarmerProfile(
      //   model.fullName!,
      //   model.farmSizeHectares!,
      //   model.farmLocation!,
      //   model.cropEntries,
      // );

      // Assume success for now
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

// Provides the list of crops from the API (Memoized)
final cropOptionsProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final apiService = ref.read(soiloApiServiceProvider);
  return apiService.fetchCropOptions();
});
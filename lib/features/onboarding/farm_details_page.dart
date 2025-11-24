// lib/features/onboarding/farm_details_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/common/primary_button.dart';
import '../../providers/farmer_onboarding_controller.dart';

class FarmDetailsPage extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const FarmDetailsPage({super.key, required this.onNext, required this.onBack});

  @override
  ConsumerState<FarmDetailsPage> createState() => _FarmDetailsPageState();
}

class _FarmDetailsPageState extends ConsumerState<FarmDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill fields from controller state
    final model = ref.read(farmerOnboardingControllerProvider).value;
    if (model != null) {
      if (model.farmSizeHectares != null) {
        _sizeController.text = model.farmSizeHectares.toString();
      }
      if (model.farmLocation != null) {
        _locationController.text = model.farmLocation!;
      }
    }
  }

  @override
  void dispose() {
    _sizeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _handleGpsLocation() async {
    final controller = ref.read(farmerOnboardingControllerProvider.notifier);

    await controller.requestLocation((error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location Error: $error'))
      );
    });

    // Update text field with new state value if successful
    final newLocation = ref.read(farmerOnboardingControllerProvider).value?.farmLocation;
    if (newLocation != null) {
      _locationController.text = newLocation;
    }
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      final size = double.tryParse(_sizeController.text);
      final location = _locationController.text.trim();

      if (size == null || location.isEmpty) return;

      // Update controller state
      ref.read(farmerOnboardingControllerProvider.notifier)
          .updateFarmDetails(size, location);

      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final modelState = ref.watch(farmerOnboardingControllerProvider);
    final isLocationLoading = modelState.isLoading;

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tell us about your primary farm:', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 24),

                    // Farm Size Field
                    TextFormField(
                      controller: _sizeController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Farm Size',
                        hintText: 'Size in Hectares (e.g., 5.5)',
                        prefixIcon: Icon(Icons.landscape),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || double.tryParse(value) == null || double.parse(value) <= 0) {
                          return 'Enter a valid farm size';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Location Field
                    TextFormField(
                      controller: _locationController,
                      readOnly: isLocationLoading,
                      decoration: InputDecoration(
                        labelText: 'Farm Location (GPS/Name)',
                        hintText: 'Enter coordinates or fetch GPS',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        suffixIcon: IconButton(
                          icon: isLocationLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : const Icon(Icons.gps_fixed),
                          onPressed: isLocationLoading ? null : _handleGpsLocation,
                          tooltip: 'Fetch current GPS location',
                        ),
                      ),
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Location is required' : null,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // --- Navigation Buttons ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: modelState.isLoading ? null : widget.onBack,
                  child: const Text('BACK'),
                ),
                FloatingActionButton.extended(
                  onPressed: modelState.isLoading ? null : _handleNext,
                  label: const Text('NEXT: Preview'),
                  icon: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
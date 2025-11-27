// lib/features/onboarding/farm_crop_datails_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/onboarding/farmer_onboarding_controller.dart';
import '../../models/onboarding/farm_detail_model.dart';
import '../../themes/app_factory.dart';
import '../../utils/ui_helpers.dart';


class FarmCropDetailsPage extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const FarmCropDetailsPage({super.key, required this.onNext, required this.onBack});

  @override
  ConsumerState<FarmCropDetailsPage> createState() => _FarmCropDetailsPageState();
}

class _FarmCropDetailsPageState extends ConsumerState<FarmCropDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  // List of mutable FarmEntry objects managed locally
  List<FarmEntry> _farmEntries = [];
  final List<TextEditingController> _locationControllers = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existingModel = ref.read(farmerOnboardingControllerProvider).value;
    if (existingModel != null && existingModel.farmEntries.isNotEmpty) {
      // Deep copy to allow local mutation
      _farmEntries = existingModel.farmEntries.map((e) => FarmEntry(
        farmSizeHectares: e.farmSizeHectares,
        farmLocation: e.farmLocation,
        cropType: e.cropType,
        dateSown: e.dateSown,
      )).toList();
      for (var farm in _farmEntries) {
        _locationControllers.add(TextEditingController(text: farm.farmLocation));
      }
    } else {
      _addFarmEntry();
    }
  }
  @override
  void dispose() {
    // 3. Always dispose controllers
    for (var controller in _locationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addFarmEntry() {
    setState(() {
      _farmEntries.add(FarmEntry(
        // Initialize with sane defaults
        cropType: '',
        dateSown: DateTime.now(),
      ));
      _locationControllers.add(TextEditingController());
    });
  }

  void _removeFarmEntry(int index) {
    setState(() {
      _farmEntries.removeAt(index);
      _locationControllers[index].dispose();
      _locationControllers.removeAt(index);
      if (_farmEntries.isEmpty) {
        _addFarmEntry(); // Always ensure at least one farm entry exists
      }
    });
  }

  Future<void> _handleGpsLocation(int index) async {
    final controller = ref.read(farmerOnboardingControllerProvider.notifier);
    // Note: We use the local _isSaving state to show loading only on the specific field
    setState(() => _isSaving = true);

    // We pass a dummy error handler; location fetching status is checked via _isSaving
    final locationString = await controller.requestLocation((error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location Error: $error'))
      );
    });

    setState(() {
      _isSaving = false;
      if (!locationString.startsWith("Error:")) {
        _farmEntries[index].farmLocation = locationString;
        // 7. Update the CONTROLLER (This updates the UI immediately)
        _locationControllers[index].text = locationString;
      }
    });
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Final validation to ensure all crucial fields are set
      final allValid = _farmEntries.every((e) =>
      e.farmSizeHectares != null && e.farmSizeHectares! > 0 &&
          e.farmLocation != null && e.farmLocation!.isNotEmpty &&
          e.cropType.isNotEmpty
      );

      if (_farmEntries.isEmpty || !allValid) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please complete all fields for every farm.'))
        );
        return;
      }

      // Update controller state with the new list
      ref.read(farmerOnboardingControllerProvider.notifier)
          .updateFarmEntries(_farmEntries);

      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeConfig = theme.extension<ThemeConfig>()!;
    final cropOptionsAsync = ref.watch(cropOptionsProvider);
    final isPageLoading = cropOptionsAsync.isLoading || _isSaving;

    // Use a unique key for the page builder if needed, but the widget key is sufficient
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Column(
          children: [
            // Ensure this is accessible via import 'farmer_onboarding_screen.dart' show ...
            PageHeader(
              title: OnboardingStep.farmAndCrops.title,
              subtitle: 'Add details for all your farm locations and the current primary crop grown.',
              theme: theme,
              themeConfig: themeConfig,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (isPageLoading && _farmEntries.isEmpty)
                      const Center(child: LinearProgressIndicator()),

                    // --- Farm Entry List ---
                    ..._farmEntries.asMap().entries.map((entry) {
                      final index = entry.key;
                      final farm = _farmEntries[index];

                      // Check if location fetching is ongoing for THIS farm
                      // Note: This only works perfectly if you limit _isSaving to the button click itself
                      final isLocationFetching = _isSaving && farm.farmLocation == null;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 24.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Farm Header and Delete Button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Farm ${index + 1}',
                                    style: theme.textTheme.titleMedium?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold),
                                  ),
                                  if (index > 0)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: isPageLoading ? null : () => _removeFarmEntry(index),
                                    ),
                                ],
                              ),
                              const Divider(),

                              // 1. Farm Size Field
                              TextFormField(
                                initialValue: farm.farmSizeHectares?.toString(),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Farm Size (Hectares)',
                                  hintText: 'e.g., 5.5',
                                  prefixIcon: Icon(Icons.landscape),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                ],
                                // FIX: Use onSaved to update the mutable FarmEntry object
                                onSaved: (value) => farm.farmSizeHectares = double.tryParse(value ?? ''),
                                validator: (value) => (value == null || double.tryParse(value) == null || double.parse(value) <= 0)
                                    ? 'Enter a valid size' : null,
                              ),
                              const SizedBox(height: 16),

                              // 2. Location Field
                              TextFormField(
                                controller: _locationControllers[index],
                                readOnly: isLocationFetching || _isSaving, // Disable input if anything is loading
                                decoration: InputDecoration(
                                  labelText: 'Farm Location (GPS/Name)',
                                  hintText: 'Fetch GPS or enter location name',
                                  prefixIcon: const Icon(Icons.location_on_outlined),
                                  suffixIcon: IconButton(
                                    icon: isLocationFetching || _isSaving
                                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                        : const Icon(Icons.gps_fixed),
                                    onPressed: isPageLoading ? null : () => _handleGpsLocation(index),
                                    tooltip: 'Fetch current GPS location',
                                  ),
                                ),
                                // FIX: Use onSaved to update the mutable FarmEntry object
                                onSaved: (value) => farm.farmLocation = value?.trim(),
                                validator: (value) => value == null || value.isEmpty ? 'Location is required' : null,
                              ),
                              const SizedBox(height: 16),

                              // 3. Crop Dropdown
                              cropOptionsAsync.when(
                                loading: () => const LinearProgressIndicator(),
                                error: (e, s) => Text('Error loading crops: $e'),
                                data: (cropOptions) {
                                  return DropdownButtonFormField<String>(
                                    initialValue: farm.cropType.isEmpty ? null : farm.cropType,
                                    decoration: const InputDecoration(
                                      labelText: 'Select Crop',
                                      prefixIcon: Icon(Icons.grass_outlined),
                                    ),
                                    items: cropOptions.map((c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c),
                                    )).toList(),
                                    // FIX: Update the mutable FarmEntry object using setState
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          farm.cropType = value;
                                        });
                                      }
                                    },
                                    onSaved: (value) => farm.cropType = value ?? '',
                                    validator: (value) => value == null ? 'Selection required' : null,
                                  );
                                },
                              ),
                              const SizedBox(height: 16),

                              // 4. Date Sown
                              TextFormField(
                                key: ValueKey('date_${index}_${farm.dateSown}'),
                                initialValue: farm.dateSownFormatted,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  labelText: 'Date Sown',
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                onTap: isPageLoading ? null : () async {
                                  final selectedDate = await showDatePicker(
                                    context: context,
                                    initialDate: farm.dateSown,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now(),
                                  );
                                  if (selectedDate != null) {
                                    setState(() {
                                      farm.dateSown = selectedDate;
                                    });
                                  }
                                },
                                validator: (value) => value == null || value.isEmpty ? 'Date is required' : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),

                    // Add Farm Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: isPageLoading ? null : _addFarmEntry,
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Add Another Farm'),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // --- Bottom Navigation Buttons ---
            BottomNavButtons(
              onBack: widget.onBack,
              onNext: _handleNext,
              nextLabel: 'NEXT: Preview',
              isLoading: isPageLoading,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
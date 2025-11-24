import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/farmer_onboarding_controller.dart';
import '../onboarding/data/models/farm_detail_model.dart';

class CropDetailsPage extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const CropDetailsPage({super.key, required this.onNext, required this.onBack});

  @override
  ConsumerState<CropDetailsPage> createState() => _CropDetailsPageState();
}

class _CropDetailsPageState extends ConsumerState<CropDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  // NOTE: Assuming CropEntry fields (cropType, dateSown) are now mutable (not final)
  List<CropEntry> _cropEntries = [];

  @override
  void initState() {
    super.initState();
    // Load existing data if present
    final existingModel = ref.read(farmerOnboardingControllerProvider).value;
    if (existingModel != null && existingModel.cropEntries.isNotEmpty) {
      // Create a deep copy of entries to allow local modification
      _cropEntries = existingModel.cropEntries.map((e) => CropEntry(
        cropType: e.cropType,
        dateSown: e.dateSown,
      )).toList();
    } else {
      _addCropEntry();
    }
  }

  void _addCropEntry() {
    setState(() {
      _cropEntries.add(CropEntry(
        cropType: '',
        dateSown: DateTime.now(),
      ));
    });
  }

  void _removeCropEntry(int index) {
    setState(() {
      _cropEntries.removeAt(index);
      if (_cropEntries.isEmpty) {
        _addCropEntry(); // Ensure at least one field remains
      }
    });
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Filter out any entries that might be visually empty but in the list
      final validEntries = _cropEntries.where((e) => e.cropType.isNotEmpty).toList();

      if (validEntries.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please add at least one crop.'))
        );
        return;
      }

      // Update controller state
      ref.read(farmerOnboardingControllerProvider.notifier)
          .updateCropEntries(validEntries);

      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // cropOptionsProvider is defined in farmer_onboarding_controller.dart
    final cropOptionsAsync = ref.watch(cropOptionsProvider);

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
                    Text('What are you currently growing?', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 24),

                    // --- Crop Entry List ---
                    ..._cropEntries.asMap().entries.map((entry) {
                      final index = entry.key;
                      // The error was here because 'crop' was final in the old version of the CropEntry model.
                      final crop = _cropEntries[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Crop ${index + 1}',
                              style: theme.textTheme.titleMedium?.copyWith(color: theme.primaryColor),
                            ),
                            const SizedBox(height: 8),

                            // Crop Dropdown
                            cropOptionsAsync.when(
                              loading: () => const LinearProgressIndicator(),
                              error: (e, s) => Text('Error loading crops: $e'),
                              data: (cropOptions) {
                                return DropdownButtonFormField<String>(
                                  value: crop.cropType.isEmpty ? null : crop.cropType,
                                  decoration: const InputDecoration(
                                    labelText: 'Select Crop',
                                    prefixIcon: Icon(Icons.grass_outlined),
                                  ),
                                  items: cropOptions.map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  )).toList(),
                                  // FIX: Use setState to ensure the UI rebuilds and the value is persisted locally
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _cropEntries[index] = CropEntry(
                                          cropType: value,
                                          dateSown: crop.dateSown,
                                        );
                                      });
                                    }
                                  },
                                  onSaved: (value) {
                                    if (value != null) {
                                      _cropEntries[index] = CropEntry(
                                        cropType: value,
                                        dateSown: crop.dateSown,
                                      );
                                    }
                                  },
                                  validator: (value) =>
                                  value == null ? 'Selection required' : null,
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // Date Sown
                            TextFormField(
                              key: ValueKey('date_${index}_${crop.dateSown}'),
                              initialValue: crop.dateSownFormatted,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Date Sown',
                                prefixIcon: const Icon(Icons.calendar_today),
                                suffixIcon: index > 0
                                    ? IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeCropEntry(index),
                                )
                                    : null,
                              ),
                              onTap: () async {
                                final selectedDate = await showDatePicker(
                                  context: context,
                                  initialDate: crop.dateSown,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                );
                                if (selectedDate != null) {
                                  setState(() {
                                    // Overwrite the existing crop entry with the new date
                                    // This assumes cropType is already set from onChanged/onSaved
                                    _cropEntries[index] = CropEntry(
                                        cropType: crop.cropType,
                                        dateSown: selectedDate
                                    );
                                  });
                                }
                              },
                              validator: (value) => value == null || value.isEmpty
                                  ? 'Date is required' : null,
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    // Add Crop Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _addCropEntry,
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Add Another Crop'),
                      ),
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
                  onPressed: widget.onBack,
                  child: const Text('BACK'),
                ),
                FloatingActionButton.extended(
                  onPressed: _handleNext,
                  label: const Text('NEXT: Farm Details'),
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
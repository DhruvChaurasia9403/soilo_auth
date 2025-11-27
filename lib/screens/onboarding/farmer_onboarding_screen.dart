// lib/features/onboarding/farmer_onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/auth/user_role.dart';
import '../../models/onboarding/farm_detail_model.dart';
import '../../utils/ui_helpers.dart';
import 'farm_crop_datails_screen.dart';
import '../../controllers/onboarding/farmer_onboarding_controller.dart';
import '../../themes/app_factory.dart';



// --- Main Screen ---
class FarmerOnboardingScreen extends ConsumerStatefulWidget {
  final String fullName;
  final UserRole role;

  const FarmerOnboardingScreen({
    super.key,
    required this.fullName,
    required this.role,
  });

  @override
  ConsumerState<FarmerOnboardingScreen> createState() =>
      FarmerOnboardingScreenState();
}

class FarmerOnboardingScreenState
    extends ConsumerState<FarmerOnboardingScreen> {
  OnboardingStep _currentStep = OnboardingStep.info;
  final PageController _pageController = PageController();
  // NEW: State to hold the language selected on Page 1
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize with data and default language
      ref.read(farmerOnboardingControllerProvider.notifier)
          .initializeProfile(
        fullName: widget.fullName,
        role: widget.role,
        language: _selectedLanguage, // Pass default language
      );
    });
  }

  void goToPage(int index) {
    if (index >= 0 && index < OnboardingStep.values.length) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void onStepSubmitted() {
    final controller = ref.read(farmerOnboardingControllerProvider.notifier);
    controller.submitOnboarding(
          () {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Onboarding complete!')));
        context.go('/home');
      },
          (error) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error))),
    );
  }

  // New callback for handling language change on Page 1
  void handleLanguageSelected(String lang) {
    setState(() {
      _selectedLanguage = lang;
    });
    ref.read(farmerOnboardingControllerProvider.notifier)
        .initializeProfile(
      fullName: widget.fullName,
      role: widget.role,
      language: lang,
    );
    goToPage(1); // Move to next page
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeConfig = theme.extension<ThemeConfig>()!;
    final model = ref.watch(farmerOnboardingControllerProvider).value;

    if (model == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [themeConfig.gradientStart, themeConfig.gradientEnd],
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 56),
              OnboardingProgressBar(
                currentStep: _currentStep,
                themeConfig: themeConfig,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) => setState(() {
                    _currentStep = OnboardingStep.values[index];
                  }),
                  children: [
                    InfoPage(
                      model: model,
                      onLanguageSelected: handleLanguageSelected, // Pass the new handler
                    ),
                    FarmCropDetailsPage( // NEW PAGE 2
                        onNext: () => goToPage(2),
                        onBack: () => goToPage(0)
                    ),
                    PreviewPage(
                      model: model,
                      onBack: () => goToPage(1),
                      onSubmit: onStepSubmitted,
                      isLoading: ref.watch(farmerOnboardingControllerProvider).isLoading,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 1. Info Page (Updated with Language Dropdown) ---
class InfoPage extends StatefulWidget {
  final FarmDetailModel model;
  final Function(String lang) onLanguageSelected;

  const InfoPage({required this.model, required this.onLanguageSelected});

  @override
  State<InfoPage> createState() => InfoPageState();
}

class InfoPageState extends State<InfoPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedLanguage;

  final List<String> _languages = ['English', 'Hindi', 'Marathi', 'Bengali'];

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.model.language ?? 'English';
  }

  void handleNext() {
    if (_formKey.currentState!.validate()) {
      widget.onLanguageSelected(_selectedLanguage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeConfig = theme.extension<ThemeConfig>()!;

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Welcome, ${widget.model.fullName}!',
              subtitle: 'Select your preferred language and proceed to farm details.',
              theme: theme,
              themeConfig: themeConfig,
            ),
            const SizedBox(height: 32),

            StyledInfoCard(
              label: "Full Name",
              value: widget.model.fullName ?? 'N/A',
              icon: Icons.person_outline,
              themeConfig: themeConfig,
              theme: theme,
            ),
            const SizedBox(height: 16),
            StyledInfoCard(
              label: "Role",
              value: widget.model.role?.displayName ?? 'N/A',
              icon: Icons.work_outline,
              themeConfig: themeConfig,
              theme: theme,
            ),
            const SizedBox(height: 24),

            // --- NEW: Language Dropdown ---
            DropdownButtonFormField<String>(
              initialValue: _selectedLanguage,
              hint: const Text('Select Language'),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.language),
                labelText: 'Preferred Language',
              ),
              items: _languages.map((lang) {
                return DropdownMenuItem(
                  value: lang,
                  child: Text(lang),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedLanguage = value),
              validator: (value) => value == null ? 'Language is required.' : null,
            ),

            const Spacer(),
            BottomNavButtons(
              onNext: handleNext,
              nextLabel: 'NEXT: Farm Details',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// --- 3. Preview Page (Updated for new model) ---
class PreviewPage extends StatelessWidget {
  final FarmDetailModel model;
  final VoidCallback onBack;
  final VoidCallback onSubmit;
  final bool isLoading;

  const PreviewPage({
    required this.model,
    required this.onBack,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeConfig = theme.extension<ThemeConfig>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Review Profile',
            subtitle: 'Please ensure all details are correct before submitting.',
            theme: theme,
            themeConfig: themeConfig,
          ),
          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(title: "Personal Details", theme: theme),
                  const SizedBox(height: 12),
                  // Compact Grid for Personal Info
                  Row(
                    children: [
                      Expanded(child: StyledInfoCard(
                          label: "Name", value: model.fullName!, icon: Icons.person, themeConfig: themeConfig, theme: theme, isCompact: true)),
                      const SizedBox(width: 12),
                      Expanded(child: StyledInfoCard(
                          label: "Role", value: model.role!.displayName, icon: Icons.work, themeConfig: themeConfig, theme: theme, isCompact: true)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  StyledInfoCard(
                      label: "Preferred Language",
                      value: model.language ?? 'N/A',
                      icon: Icons.language,
                      themeConfig: themeConfig,
                      theme: theme
                  ),

                  const SizedBox(height: 24),
                  SectionHeader(title: "Farms & Crops (${model.farmEntries.length})", theme: theme),
                  const SizedBox(height: 12),
                  if (model.farmEntries.isEmpty)
                    Text("No farms added.", style: theme.textTheme.bodyMedium),

                  // Display all farm entries
                  ...model.farmEntries.asMap().entries.map((entry) {
                    final index = entry.key;
                    final farm = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Farm ${index + 1}", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const Divider(),
                            StyledInfoCard(
                                label: "Size",
                                value: "${farm.farmSizeHectares?.toStringAsFixed(2) ?? 'N/A'} Hectares",
                                icon: Icons.landscape,
                                themeConfig: themeConfig,
                                theme: theme,
                                isCompact: true
                            ),
                            const SizedBox(height: 8),
                            StyledInfoCard(
                                label: "Location",
                                value: farm.farmLocation ?? 'N/A',
                                icon: Icons.location_on,
                                themeConfig: themeConfig,
                                theme: theme,
                                isCompact: true
                            ),
                            const SizedBox(height: 8),
                            StyledInfoCard(
                                label: "Current Crop",
                                value: "${farm.cropType} (Sown: ${farm.dateSownFormatted})",
                                icon: Icons.grass,
                                themeConfig: themeConfig,
                                theme: theme,
                                isCompact: true
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 40), // Bottom padding
                ],
              ),
            ),
          ),

          // Bottom Buttons
          BottomNavButtons(
            onBack: onBack,
            onNext: onSubmit,
            nextLabel: 'CONFIRM & SUBMIT',
            nextIcon: Icons.check,
            isLoading: isLoading,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
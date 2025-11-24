// lib/features/onboarding/farmer_onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/user_role.dart';
import '../../providers/farmer_onboarding_controller.dart';
import '../../themes/app_factory.dart';
import 'data/models/farm_detail_model.dart'; // Ensure correct model import
import 'farm_details_page.dart';
import 'crop_details_page.dart';

// Represents the three distinct steps in the form
// This enum is correct and does not contain the error final int index;
enum OnboardingStep {
  info,
  crops,
  farmDetails,
  preview,
}

extension OnboardingStepExt on OnboardingStep {
  String get title {
    switch (this) {
      case OnboardingStep.info:
        return 'User Info';
      case OnboardingStep.crops:
        return 'Crop Details';
      case OnboardingStep.farmDetails:
        return 'Farm Location & Size';
      case OnboardingStep.preview:
        return 'Review & Submit';
    }
  }
}


class FarmerOnboardingScreen extends ConsumerStatefulWidget {
  final String fullName;
  final UserRole role;

  const FarmerOnboardingScreen({
    super.key,
    required this.fullName,
    required this.role,
  });

  @override
  ConsumerState<FarmerOnboardingScreen> createState() => _FarmerOnboardingScreenState();
}

class _FarmerOnboardingScreenState extends ConsumerState<FarmerOnboardingScreen> {
  OnboardingStep _currentStep = OnboardingStep.info;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the data passed from signup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(farmerOnboardingControllerProvider.notifier)
          .initializeProfile(widget.fullName, widget.role);
    });
  }

  void _nextPage() {
    final nextIndex = _currentStep.index + 1;
    if (nextIndex < OnboardingStep.values.length) {
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void _previousPage() {
    final prevIndex = _currentStep.index - 1;
    if (prevIndex >= 0) {
      _pageController.animateToPage(
        prevIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void _onStepSubmitted() {
    final controller = ref.read(farmerOnboardingControllerProvider.notifier);

    controller.submitOnboarding(
          () {
        // Handle success, maybe navigate to Home
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Onboarding complete!'))
        );
        context.go('/home');
      },
          (error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error))
        );
      },
    );
  }

  Widget _buildStep(OnboardingStep step) {
    final model = ref.watch(farmerOnboardingControllerProvider).value;
    if (model == null) return const Center(child: CircularProgressIndicator());

    switch (step) {
      case OnboardingStep.info:
        return _InfoPage(model: model, onNext: _nextPage);
      case OnboardingStep.crops:
        return CropDetailsPage(onNext: _nextPage, onBack: _previousPage);
      case OnboardingStep.farmDetails:
        return FarmDetailsPage(onNext: _nextPage, onBack: _previousPage);
      case OnboardingStep.preview:
        return _PreviewPage(
          model: model,
          onBack: _previousPage,
          onSubmit: _onStepSubmitted,
          isLoading: ref.watch(farmerOnboardingControllerProvider).isLoading,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeConfig = theme.extension<ThemeConfig>()!;

    return PopScope(
      canPop: false, // Prevent back navigation while in onboarding
      child: Scaffold(
        appBar: AppBar(
          title: Text('Farmer Onboarding (${_currentStep.title})'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _currentStep == OnboardingStep.info ? null : _previousPage,
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [themeConfig.gradientStart, themeConfig.gradientEnd],
            ),
          ),
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // Managed by buttons
            onPageChanged: (index) {
              setState(() {
                _currentStep = OnboardingStep.values[index];
              });
            },
            children: OnboardingStep.values.map(_buildStep).toList(),
          ),
        ),
      ),
    );
  }
}

// --- Internal Step 1: Info Page (Pre-filled) ---
class _InfoPage extends StatelessWidget {
  final FarmDetailModel model;
  final VoidCallback onNext;

  const _InfoPage({required this.model, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome, ${model.fullName}!', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('We need a few more details to set up your account for personalized farm intelligence.', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 32),
          // Display Pre-filled Info
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Full Name'),
            subtitle: Text(model.fullName ?? 'N/A'),
          ),
          ListTile(
            leading: const Icon(Icons.work),
            title: const Text('Role'),
            subtitle: Text(model.role?.displayName ?? 'N/A'),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton.extended(
              onPressed: onNext,
              label: const Text('NEXT: Crops'),
              icon: const Icon(Icons.arrow_forward),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Internal Step 4: Preview Page ---
class _PreviewPage extends ConsumerWidget {
  final FarmDetailModel model;
  final VoidCallback onBack;
  final VoidCallback onSubmit;
  final bool isLoading;

  const _PreviewPage({
    required this.model,
    required this.onBack,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review Your Profile', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          // --- User Info ---
          Text('1. Personal Details', style: theme.textTheme.titleLarge),
          Text('Name: ${model.fullName}', style: theme.textTheme.bodyMedium),
          Text('Role: ${model.role?.displayName}', style: theme.textTheme.bodyMedium),
          const Divider(),

          // --- Crop Details ---
          Text('2. Crop Details', style: theme.textTheme.titleLarge),
          if (model.cropEntries.isEmpty)
            Text('No crops added.', style: theme.textTheme.bodyMedium),
          ...model.cropEntries.map((entry) =>
              Text('• ${entry.cropType} (Sown: ${entry.dateSownFormatted})', style: theme.textTheme.bodyMedium)),
          const Divider(),

          // --- Farm Details ---
          Text('3. Farm Details', style: theme.textTheme.titleLarge),
          Text('Size: ${model.farmSizeHectares?.toStringAsFixed(2) ?? 'N/A'} Hectares', style: theme.textTheme.bodyMedium),
          Text('Location: ${model.farmLocation ?? 'N/A'}', style: theme.textTheme.bodyMedium),

          const Spacer(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: isLoading ? null : onBack,
                child: const Text('BACK'),
              ),
              FloatingActionButton.extended(
                onPressed: isLoading ? null : onSubmit,
                label: isLoading
                    ? const Row(
                  children: [
                    SizedBox(width: 8),
                    CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  ],
                )
                    : const Text('CONFIRM & SUBMIT'),
                icon: const Icon(Icons.check),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
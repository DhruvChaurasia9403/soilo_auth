// lib/features/onboarding/farmer_onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/user_role.dart';
import '../../providers/farmer_onboarding_controller.dart';
import '../../themes/app_factory.dart';
import 'data/models/farm_detail_model.dart';
import 'farm_details_page.dart';
import 'crop_details_page.dart';

// --- Enums & Extensions ---
enum OnboardingStep { info, crops, farmDetails, preview }

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
      _FarmerOnboardingScreenState();
}

class _FarmerOnboardingScreenState
    extends ConsumerState<FarmerOnboardingScreen> {
  OnboardingStep _currentStep = OnboardingStep.info;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(farmerOnboardingControllerProvider.notifier)
          .initializeProfile(widget.fullName, widget.role);
    });
  }

  void _goToPage(int index) {
    if (index >= 0 && index < OnboardingStep.values.length) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void _onStepSubmitted() {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeConfig = theme.extension<ThemeConfig>()!;
    final model = ref.watch(farmerOnboardingControllerProvider).value;

    // Show loading if model isn't ready
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
              // Extracted Progress Bar
              _OnboardingProgressBar(
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
                    _InfoPage(
                        model: model,
                        onNext: () => _goToPage(1)
                    ),
                    CropDetailsPage(
                        onNext: () => _goToPage(2),
                        onBack: () => _goToPage(0)
                    ),
                    FarmDetailsPage(
                        onNext: () => _goToPage(3),
                        onBack: () => _goToPage(1)
                    ),
                    _PreviewPage(
                      model: model,
                      onBack: () => _goToPage(2),
                      onSubmit: _onStepSubmitted,
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

// --- 1. Info Page ---
class _InfoPage extends StatelessWidget {
  final FarmDetailModel model;
  final VoidCallback onNext;

  const _InfoPage({required this.model, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeConfig = theme.extension<ThemeConfig>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PageHeader(
            title: 'Welcome, ${model.fullName}!',
            subtitle: 'We need a few more details to set up your account for personalized farm intelligence.',
            theme: theme,
            themeConfig: themeConfig,
          ),
          const SizedBox(height: 32),

          _StyledInfoCard(
            label: "Full Name",
            value: model.fullName ?? 'N/A',
            icon: Icons.person_outline,
            themeConfig: themeConfig,
            theme: theme,
          ),
          const SizedBox(height: 16),
          _StyledInfoCard(
            label: "Role",
            value: model.role?.displayName ?? 'N/A',
            icon: Icons.work_outline,
            themeConfig: themeConfig,
            theme: theme,
          ),
          const Spacer(),
          _BottomNavButtons(
            onNext: onNext,
            nextLabel: 'NEXT: Crops',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// --- 4. Preview Page (Redesigned) ---
class _PreviewPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeConfig = theme.extension<ThemeConfig>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PageHeader(
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
                  _SectionHeader(title: "Personal Details", theme: theme),
                  const SizedBox(height: 12),
                  // Compact Grid for Personal Info
                  Row(
                    children: [
                      Expanded(child: _StyledInfoCard(
                          label: "Name", value: model.fullName!, icon: Icons.person, themeConfig: themeConfig, theme: theme, isCompact: true)),
                      const SizedBox(width: 12),
                      Expanded(child: _StyledInfoCard(
                          label: "Role", value: model.role!.displayName, icon: Icons.work, themeConfig: themeConfig, theme: theme, isCompact: true)),
                    ],
                  ),

                  const SizedBox(height: 24),
                  _SectionHeader(title: "Farm Details", theme: theme),
                  const SizedBox(height: 12),
                  _StyledInfoCard(
                      label: "Size",
                      value: "${model.farmSizeHectares?.toStringAsFixed(2) ?? 'N/A'} Hectares",
                      icon: Icons.landscape,
                      themeConfig: themeConfig,
                      theme: theme
                  ),
                  const SizedBox(height: 12),
                  _StyledInfoCard(
                      label: "Location",
                      value: model.farmLocation ?? 'N/A',
                      icon: Icons.location_on,
                      themeConfig: themeConfig,
                      theme: theme
                  ),

                  const SizedBox(height: 24),
                  _SectionHeader(title: "Crops", theme: theme),
                  const SizedBox(height: 12),
                  if (model.cropEntries.isEmpty)
                    Text("No crops added", style: theme.textTheme.bodyMedium),
                  ...model.cropEntries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _StyledInfoCard(
                      label: "Sown: ${e.dateSownFormatted}",
                      value: e.cropType,
                      icon: Icons.grass,
                      themeConfig: themeConfig,
                      theme: theme,
                      isCompact: true,
                    ),
                  )),
                  const SizedBox(height: 40), // Bottom padding
                ],
              ),
            ),
          ),

          // Bottom Buttons
          _BottomNavButtons(
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

// =============================================================================
// REUSABLE UI COMPONENTS (Keep code clean & short)
// =============================================================================

class _StyledInfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final ThemeConfig themeConfig;
  final ThemeData theme;
  final bool isCompact;

  const _StyledInfoCard({
    required this.label, required this.value, required this.icon,
    required this.themeConfig, required this.theme, this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: BoxDecoration(
        color: themeConfig.inputFillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeConfig.inputBorder, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align to top for multi-line
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themeConfig.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: themeConfig.primaryColor, size: isCompact ? 20 : 24),
          ),
          SizedBox(width: isCompact ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: theme.textTheme.bodySmall?.copyWith(color: themeConfig.inputLabel, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value, style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold, fontSize: isCompact ? 14 : 16, color: themeConfig.textColor
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingProgressBar extends StatelessWidget {
  final OnboardingStep currentStep;
  final ThemeConfig themeConfig;

  const _OnboardingProgressBar({required this.currentStep, required this.themeConfig});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
      child: Row(
        children: OnboardingStep.values.map((step) {
          final isCompleted = step.index < currentStep.index;
          final isActive = step.index == currentStep.index;
          final isLast = step.index == OnboardingStep.values.length - 1;

          return Expanded(
            flex: isLast ? 0 : 1,
            child: Row(
              children: [
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive || isCompleted ? themeConfig.primaryColor : Colors.transparent,
                    border: Border.all(
                        color: isActive || isCompleted ? themeConfig.primaryColor : Colors.grey.withOpacity(0.5), width: 1.5),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : Text('${step.index + 1}', style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey.withOpacity(0.8),
                        fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      height: 2, margin: const EdgeInsets.symmetric(horizontal: 4),
                      color: isCompleted ? themeConfig.primaryColor.withOpacity(0.8) : Colors.grey.withOpacity(0.3),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BottomNavButtons extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback onNext;
  final String nextLabel;
  final IconData nextIcon;
  final bool isLoading;

  const _BottomNavButtons({
    this.onBack, required this.onNext, required this.nextLabel,
    this.nextIcon = Icons.arrow_forward, this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (onBack != null)
          TextButton(onPressed: isLoading ? null : onBack, child: const Text('BACK'))
        else
          const SizedBox(), // Spacer if no back button

        FloatingActionButton.extended(
          heroTag: "onboarding_nav_btn", // Unique tag
          onPressed: isLoading ? null : onNext,
          label: isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(nextLabel),
          icon: isLoading ? null : Icon(nextIcon),
        ),
      ],
    );
  }
}

class _PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final ThemeData theme;
  final ThemeConfig themeConfig;

  const _PageHeader({required this.title, required this.subtitle, required this.theme, required this.themeConfig});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(title, style: theme.textTheme.headlineSmall?.copyWith(color: themeConfig.primaryColor, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: themeConfig.textColor.withOpacity(0.8), height: 1.5)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final ThemeData theme;
  const _SectionHeader({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold));
  }
}
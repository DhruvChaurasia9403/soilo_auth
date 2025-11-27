// lib/utils/ui_helpers.dart

import 'package:flutter/material.dart';

import '../themes/app_factory.dart';
import 'constants.dart';

// --- Enums & Extensions (Moved from farmer_onboarding_screen.dart) ---
enum OnboardingStep { info, farmAndCrops, preview }


// Verification purposes for OTP screen
enum VerificationPurpose {
  signUp,
  login,
  passwordReset,
}

extension OnboardingStepExtension on OnboardingStep {
  String get title {
    switch (this) {
      case OnboardingStep.info:
        return 'Personal Info';
      case OnboardingStep.farmAndCrops:
        return 'Farm & Crop Details';
      case OnboardingStep.preview:
        return 'Review & Submit';
    }
  }
}



void showPasswordRules(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Password Rules'),
      // OLD: Text(AppValidators.passwordRules),
      content: const Text(kPasswordRules), // NEW: Use constant
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

// --- REUSABLE UI COMPONENTS (StyledInfoCard, ProgressBar, Buttons, Headers) ---

class StyledInfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final ThemeConfig themeConfig;
  final ThemeData theme;
  final bool isCompact;

  const StyledInfoCard({
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
        crossAxisAlignment: CrossAxisAlignment.start,
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

class OnboardingProgressBar extends StatelessWidget {
  final OnboardingStep currentStep;
  final ThemeConfig themeConfig;

  const OnboardingProgressBar({required this.currentStep, required this.themeConfig});

  @override
  Widget build(BuildContext context) {
    // ...
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

class BottomNavButtons extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback onNext;
  final String nextLabel;
  final IconData nextIcon;
  final bool isLoading;

  const BottomNavButtons({
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
          const SizedBox(),

        FloatingActionButton.extended(
          heroTag: "onboarding_nav_btn",
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

class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final ThemeData theme;
  final ThemeConfig themeConfig;

  const PageHeader({required this.title, required this.subtitle, required this.theme, required this.themeConfig});

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

class SectionHeader extends StatelessWidget {
  final String title;
  final ThemeData theme;
  const SectionHeader({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold));
  }
}
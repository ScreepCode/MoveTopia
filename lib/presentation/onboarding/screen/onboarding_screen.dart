import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/presentation/onboarding/providers/health_connect_provider.dart';
import 'package:movetopia/presentation/onboarding/providers/onboarding_provider.dart';
import 'package:movetopia/presentation/onboarding/providers/permissions_provider.dart';
import 'package:movetopia/presentation/onboarding/widgets/features_page.dart';
import 'package:movetopia/presentation/onboarding/widgets/health_connect_page.dart';
import 'package:movetopia/presentation/onboarding/widgets/permissions_page.dart';
import 'package:movetopia/presentation/onboarding/widgets/welcome_page.dart';
import 'package:movetopia/presentation/today/routes.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// Defines the types of onboarding pages
enum OnboardingPageType {
  /// Optional pages that can be skipped
  niceToHave,

  /// Required pages that must be completed
  mustHave,
}

/// Defines an onboarding page with its properties
class OnboardingPageConfig {
  final Widget page;
  final OnboardingPageType type;
  final bool Function(WidgetRef ref) isEnabled;
  final bool Function(WidgetRef ref) isCompleted;
  final StateNotifierProvider? relatedProvider;

  const OnboardingPageConfig({
    required this.page,
    required this.type,
    required this.isEnabled,
    required this.isCompleted,
    this.relatedProvider,
  });
}

/// Creates a provider that combines the state of all required onboarding steps
final onboardingRequirementsProvider = Provider.autoDispose<bool>((ref) {
  // Watch the health connect provider to react to its changes
  final healthConnectState = ref.watch(healthConnectProvider);

  // Watch the permissions provider to react to its changes
  final permissionsState = ref.watch(permissionsProvider);

  // Calculate if Health Connect is required and if so, is it installed
  final isHealthConnectInstalled = !Platform.isAndroid ||
      !healthConnectState.isAndroidBelow14 ||
      healthConnectState.isHealthConnectInstalled;

  // Calculate if all requirements are met
  return isHealthConnectInstalled && permissionsState.hasRequiredPermissions;
});

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final controller = PageController();
    final onboardingState = ref.watch(onboardingProvider);
    final healthConnectState = ref.watch(healthConnectProvider);
    final theme = Theme.of(context);

    // Watch the requirements provider to automatically update when any requirement changes
    final allRequirementsMet = ref.watch(onboardingRequirementsProvider);

    // Check if Health Connect page should be shown
    final showHealthConnectPage =
        Platform.isAndroid && healthConnectState.isAndroidBelow14;

    // Define all onboarding pages with their properties
    final onboardingPages = [
      // Welcome page - Nice to Have
      OnboardingPageConfig(
        page: const WelcomePage(),
        type: OnboardingPageType.niceToHave,
        isEnabled: (_) => true,
        isCompleted: (_) => true,
      ),

      // Features page - Nice to Have
      OnboardingPageConfig(
        page: const FeaturesPage(),
        type: OnboardingPageType.niceToHave,
        isEnabled: (_) => true,
        isCompleted: (_) => true,
      ),

      // Health Connect page - Must Have, only shown on Android below 14
      if (showHealthConnectPage)
        OnboardingPageConfig(
          page: const HealthConnectPage(),
          type: OnboardingPageType.mustHave,
          relatedProvider: healthConnectProvider,
          isEnabled: (_) => true,
          isCompleted: (ref) =>
              !showHealthConnectPage ||
              ref.read(healthConnectProvider).isHealthConnectInstalled,
        ),

      // Permissions page - Must Have
      OnboardingPageConfig(
        page: const PermissionsPage(),
        type: OnboardingPageType.mustHave,
        relatedProvider: permissionsProvider,
        isEnabled: (ref) =>
            !showHealthConnectPage ||
            ref.read(healthConnectProvider).isHealthConnectInstalled,
        isCompleted: (ref) =>
            ref.read(permissionsProvider).hasRequiredPermissions,
      ),
    ];

    // Current page index
    final currentPageIndex = onboardingState.currentPage;

    // Get the first must-have page index
    final firstMustHavePageIndex = onboardingPages
        .indexWhere((config) => config.type == OnboardingPageType.mustHave);

    // Check if current page is in the nice-to-have section
    final isInNiceToHaveSection = currentPageIndex < firstMustHavePageIndex;

    // Check if current page is in the must-have section
    final isInMustHaveSection = currentPageIndex >= firstMustHavePageIndex;

    // Check if current page is the last page
    final isLastPage = currentPageIndex == onboardingPages.length - 1;

    // Check if current page can be proceeded from (requirements are met)
    final canProceedFromCurrentPage =
        onboardingPages[currentPageIndex].isCompleted(ref);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: currentPageIndex > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  controller.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                },
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: controller,
                physics: isInMustHaveSection && !canProceedFromCurrentPage
                    ? const NeverScrollableScrollPhysics() // Prevent swiping if requirements not met
                    : const PageScrollPhysics(),
                onPageChanged: (index) {
                  ref.read(onboardingProvider.notifier).setCurrentPage(index);

                  // Refresh health connect status when navigating to the Health Connect page
                  if (showHealthConnectPage &&
                      onboardingPages[index].page is HealthConnectPage) {
                    ref
                        .read(healthConnectProvider.notifier)
                        .forceRefreshAfterResuming();
                  }
                },
                children: onboardingPages.map((config) => config.page).toList(),
              ),
            ),

            // Bottom Navigation
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip button - only shown in Nice to Have section
                  Expanded(
                    child: isInNiceToHaveSection
                        ? TextButton(
                            onPressed: () {
                              // Animate to first Must Have page instead of jumping
                              controller.animateToPage(
                                firstMustHavePageIndex,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Text(l10n.onboarding_skip),
                          )
                        : const SizedBox.shrink(),
                  ),

                  // Dot indicators
                  Expanded(
                    child: Center(
                      child: SmoothPageIndicator(
                        controller: controller,
                        count: onboardingPages.length,
                        effect: ScrollingDotsEffect(
                          spacing: 16,
                          dotColor: theme.colorScheme.surfaceContainerHighest,
                          activeDotColor: theme.colorScheme.primary,
                          dotHeight: 10,
                          dotWidth: 10,
                        ),
                        onDotClicked: (index) {
                          // Allow skip only if the page is enabled
                          if (onboardingPages[index].isEnabled(ref)) {
                            controller.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                    ),
                  ),

                  // Next/Done button
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: !isLastPage
                          ? FilledButton(
                              onPressed: isInMustHaveSection &&
                                      !canProceedFromCurrentPage
                                  ? null // Disable button if requirements not met
                                  : () {
                                      controller.nextPage(
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                              child: Text(l10n.onboarding_next),
                            )
                          : FilledButton(
                              onPressed: allRequirementsMet
                                  ? () async {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );

                                      await ref
                                          .read(onboardingProvider.notifier)
                                          .completeOnboarding();

                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                        context.go(todayPath);
                                      }
                                    }
                                  : null,
                              child: Text(l10n.onboarding_done),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

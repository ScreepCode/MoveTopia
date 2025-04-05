import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/presentation/onboarding/providers/onboarding_provider.dart';
import 'package:movetopia/presentation/onboarding/providers/permissions_provider.dart';
import 'package:movetopia/presentation/onboarding/widgets/features_page.dart';
import 'package:movetopia/presentation/onboarding/widgets/permissions_page.dart';
import 'package:movetopia/presentation/onboarding/widgets/welcome_page.dart';
import 'package:movetopia/presentation/today/routes.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends HookConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final controller = PageController();
    final onboardingState = ref.watch(onboardingProvider);
    final permissionsState = ref.watch(permissionsProvider);
    final isLastPage = onboardingState.currentPage == 2;
    final theme = Theme.of(context);

    final allRequiredPermissionsGranted =
        permissionsState.hasRequiredPermissions;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: onboardingState.currentPage > 0
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
                onPageChanged: (index) {
                  ref.read(onboardingProvider.notifier).setCurrentPage(index);
                },
                children: const [
                  WelcomePage(),
                  FeaturesPage(),
                  PermissionsPage(),
                ],
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
                  if (!isLastPage)
                    TextButton(
                      onPressed: () {
                        controller.jumpToPage(2);
                      },
                      child: Text(l10n.onboarding_skip),
                    )
                  else
                    const SizedBox(width: 120),

                  // Dot indicators
                  Center(
                    child: SmoothPageIndicator(
                      controller: controller,
                      count: 3,
                      effect: ScrollingDotsEffect(
                        spacing: 16,
                        dotColor: theme.colorScheme.surfaceContainerHighest,
                        activeDotColor: theme.colorScheme.primary,
                        dotHeight: 10,
                        dotWidth: 10,
                      ),
                      onDotClicked: (index) => controller.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      ),
                    ),
                  ),

                  SizedBox(
                    width: 120,
                    child: !isLastPage
                        ? FilledButton(
                            onPressed: () {
                              controller.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Text(l10n.onboarding_next),
                          )
                        : FilledButton(
                            onPressed: allRequiredPermissionsGranted
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

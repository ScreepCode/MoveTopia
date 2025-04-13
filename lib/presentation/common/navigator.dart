import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/presentation/activities/routes.dart';
import 'package:movetopia/presentation/challenges/routes.dart';
import 'package:movetopia/presentation/profile/routes.dart';
import 'package:movetopia/presentation/today/routes.dart';

class MoveTopiaNavigator extends HookConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MoveTopiaNavigator({super.key, required this.navigationShell});

  bool _isRootRoute(BuildContext context) {
    final currentLocation = GoRouterState.of(context).fullPath;

    return currentLocation == todayPath ||
        currentLocation == activitiesListPath ||
        currentLocation == challengesPath ||
        currentLocation == profilePath;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isRootRoute = _isRootRoute(context);

    // Get system insets via MediaQuery
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      // For screens with bottom navigation, we modify the body to handle insets differently
      body: MediaQuery(
        // Remove bottom padding from content area when showing navigation bar
        // This ensures content in all screens is properly inset
        data: isRootRoute
            ? mediaQuery.copyWith(
                padding: mediaQuery.padding.copyWith(bottom: 0),
                viewPadding: mediaQuery.viewPadding.copyWith(bottom: 0),
                viewInsets: mediaQuery.viewInsets,
              )
            : mediaQuery,
        child: SafeArea(
          // Only apply bottom padding on screens without bottom navigation
          bottom: !isRootRoute,
          child: navigationShell,
        ),
      ),
      // Bottom navigation bar that extends behind system navigation
      bottomNavigationBar: isRootRoute
          ? NavigationBarTheme(
              data: NavigationBarThemeData(
                // Ensure the height is appropriate to prevent extra padding
                height: 80,
                indicatorColor:
                    Theme.of(context).colorScheme.secondaryContainer,
              ),
              child: NavigationBar(
                backgroundColor: Theme.of(context).colorScheme.surface,
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: (int index) =>
                    navigationShell.goBranch(index),
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.today),
                    label: l10n.navigation_today,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.list),
                    label: l10n.navigation_activities,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.emoji_events),
                    label: l10n.navigation_challenges,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.person),
                    label: l10n.navigation_profile,
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/presentation/activities/routes.dart';
import 'package:movetopia/presentation/challanges/routes.dart';
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

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _isRootRoute(context)
          ? NavigationBar(
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
            )
          : null,
    );
  }
}

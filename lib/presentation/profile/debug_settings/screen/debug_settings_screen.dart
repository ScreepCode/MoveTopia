import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../routes.dart';
import '../provider/debug_provider.dart';
import '../widgets/app_dates_section.dart';
import '../widgets/badge_debug_section.dart';
import '../widgets/streak_debug_section.dart';

class DebugSettingsScreen extends HookConsumerWidget {
  const DebugSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDebugBuild = ref.watch(isDebugBuildProvider);
    final isLoading = useState<bool>(false);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsDebugTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'App Logs',
            onPressed: () {
              context.go('/$profilePath/$profileLoggingPath');
            },
          ),
        ],
      ),
      body: isDebugBuild.when(
        data: (isDebug) {
          if (!isDebug) {
            return Center(
              child: Text(
                l10n.settingsDebugNotAvailable,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                // Titel
                Text(
                  l10n.settingsDebugMenu,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                // Debug-Sektionen direkt eingebunden
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    // App-Daten Sektion
                    const AppDatesSection(),

                    // Streak Debugging Sektion
                    StreakDebugSection(isLoading: isLoading),

                    // Badge Debugging Sektion
                    BadgeDebugSection(isLoading: isLoading),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Error: $error',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
    );
  }
}

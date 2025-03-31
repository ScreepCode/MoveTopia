import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../provider/debug_provider.dart';
import '../widgets/debug_section.dart';

class DebugSettingsScreen extends ConsumerWidget {
  const DebugSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDebugBuild = ref.watch(isDebugBuildProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsDebugTitle),
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
              children: [
                // Titel
                Text(
                  l10n.settingsDebugMenu,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),

                // Debug-Sektionen
                const DebugSection(),

                // Hier könnten weitere Debug-Sektionen hinzugefügt werden
                // z.B. für Badge-Debugging
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

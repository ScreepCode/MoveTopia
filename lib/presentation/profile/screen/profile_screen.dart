import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../settings/routes.dart';
import 'widgets/activity_goals_section.dart';
import 'widgets/profile_stats_section.dart';

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navigation_profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push(settingsPath);
            },
            tooltip: l10n.common_settings,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: ListView(
            children: <Widget>[
              // User profile statistics
              ProfileStatsSection(ref: ref),
              const SizedBox(height: 24),

              // Activity Goals Section
              ActivityGoalsSection(ref: ref),
            ],
          ),
        ),
      ),
    );
  }
}

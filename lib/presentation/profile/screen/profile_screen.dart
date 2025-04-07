import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../debug_settings/provider/debug_provider.dart';
import 'widgets/about_section.dart';
import 'widgets/activity_goals_section.dart';
import 'widgets/settings_section.dart';

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final packageInfoFuture = useMemoized(() => PackageInfo.fromPlatform());
    final isDebugBuild = ref.watch(isDebugBuildProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navigation_profile),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: ListView(
            children: <Widget>[
              ActivityGoalsSection(ref: ref),
              SettingsSection(ref: ref, isDebugBuild: isDebugBuild),
              AboutSection(ref: ref, packageInfoFuture: packageInfoFuture),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../profile/debug_settings/provider/debug_provider.dart';
import '../../profile/screen/widgets/about_section.dart';
import '../../profile/screen/widgets/settings_section.dart';

/// Screen for app settings and about information
class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final packageInfoFuture = useMemoized(() => PackageInfo.fromPlatform());
    final isDebugBuild = ref.watch(isDebugBuildProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.common_settings),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: ListView(
          children: <Widget>[
            SettingsSection(ref: ref, isDebugBuild: isDebugBuild),
            AboutSection(ref: ref, packageInfoFuture: packageInfoFuture),
          ],
        ),
      ),
    );
  }
}

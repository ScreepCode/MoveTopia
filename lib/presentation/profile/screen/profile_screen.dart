import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../provider/debug_provider.dart';
import '../routes.dart';
import '../view_model/profile_view_model.dart';

final logger = Logger('ProfileScreen');

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
              _buildActivityGoals(context, ref),
              _buildSettings(context, ref, isDebugBuild),
              _buildAboutSection(context, packageInfoFuture),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityGoals(BuildContext context, WidgetRef ref) {
    final stepsGoal = ref.watch(profileProvider).stepGoal;
    TextEditingController stepsInputController =
        TextEditingController(text: stepsGoal.toString());
    FocusNode stepsFocusNode = FocusNode();
    stepsFocusNode.addListener(() {
      if (!stepsFocusNode.hasFocus) {
        final stepGoal = int.tryParse(stepsInputController.text);
        if (stepGoal != null) {
          ref.read(profileProvider.notifier).setStepGoal(stepGoal);
        } else {
          stepsInputController.text = stepsGoal.toString();
        }
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.goal_activities_title,
                  style: Theme.of(context).textTheme.titleMedium),
              const Divider()
            ],
          ),
        ),
        TextField(
          controller: stepsInputController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.goal_steps_title,
            hintText: AppLocalizations.of(context)!.goal_steps_set_goal,
            border: const OutlineInputBorder(),
          ),
          focusNode: stepsFocusNode,
          onTapOutside: (context) {
            stepsFocusNode.unfocus();
          },
        ),
      ],
    );
  }

  Widget _buildSettings(
      BuildContext context, WidgetRef ref, AsyncValue<bool> isDebugBuild) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = ref.read(profileProvider).isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.navigation_app_settings,
                  style: Theme.of(context).textTheme.titleMedium),
              const Divider()
            ],
          ),
        ),
        SwitchListTile(
          title: Text(l10n.common_dark_mode),
          contentPadding: EdgeInsets.zero,
          value: isDarkMode,
          onChanged: (value) {
            ref.read(profileProvider.notifier).setIsDarkMode(value);
            logger.info('Change in Dropdown');
          },
        ),

        // App permissions
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.security),
          title: Text(l10n.permission_settings_title),
          subtitle: Text(l10n.permission_settings_subtitle),
          onTap: () {
            context.go('$profilePath/$profilePermissionsPath');
          },
        ),

        // Debug-Einstellungen Link, nur im Debug-Build zeigen
        isDebugBuild.when(
          data: (isDebug) {
            if (!isDebug) return const SizedBox.shrink();

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.bug_report, color: Colors.red),
              title: Text(
                l10n.settingsDebugTitle,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () {
                context.go('$profilePath/$profileDebugPath');
              },
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildAboutSection(
      BuildContext context, Future<PackageInfo> packageInfoFuture) {
    return FutureBuilder<PackageInfo>(
      future: packageInfoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text(AppLocalizations.of(context)!.common_error_version);
        } else {
          final packageInfo = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.common_about,
                    style: Theme.of(context).textTheme.titleMedium),
                const Divider(),
                Text(
                  "${AppLocalizations.of(context)!.common_version}: ${packageInfo.version}",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

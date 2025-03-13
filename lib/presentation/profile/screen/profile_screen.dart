import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../view_model/profile_view_model.dart';

final logger = Logger('ProfileScreen');

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfoFuture = useMemoized(() => PackageInfo.fromPlatform());
    final profileViewModel = ref.read(profileProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.navigation_profile),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildActivityGoals(context, ref),
              _buildSettings(context, ref),
              _buildAboutSection(context, packageInfoFuture),
              _buildCounter(context, profileViewModel),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          profileViewModel.incrementCount();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
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

  Widget _buildSettings(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.read(profileProvider).isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.navigation_app_settings,
                  style: Theme.of(context).textTheme.titleMedium),
              const Divider()
            ],
          ),
        ),
        SwitchListTile(
          title: Text(AppLocalizations.of(context)!.common_dark_mode),
          contentPadding: EdgeInsets.zero,
          value: isDarkMode,
          onChanged: (value) {
            ref.read(profileProvider.notifier).setIsDarkMode(value);
            logger.info('Change in Dropdown');
          },
        ),
      ],
    );
  }

  Widget _buildCounter(
      BuildContext context, ProfileViewModel profileViewModel) {
    final count = profileViewModel.count;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        "${AppLocalizations.of(context)!.common_counter}: $count",
        style: Theme.of(context).textTheme.titleMedium,
      ),
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

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:movetopia/presentation/me/view_model/profile_view_model.dart';

final logger = Logger('ProfileScreen');

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildActivityGoals(context, ref),
              _buildSettings(context, ref),
              _buildCounter(context, ref),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(profileProvider.notifier).incrementCount();
          logger.info('Increment button pressed');
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
              Text(AppLocalizations.of(context)!.activityGoals,
                  style: Theme.of(context).textTheme.titleMedium),
              const Divider()
            ],
          ),
        ),
        TextField(
          controller: stepsInputController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.stepGoal,
            hintText: AppLocalizations.of(context)!.enterStepGoal,
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
    final isDarkMode = ref.watch(profileProvider).isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.app_settings,
                  style: Theme.of(context).textTheme.titleMedium),
              const Divider()
            ],
          ),
        ),
        SwitchListTile(
          title: Text(AppLocalizations.of(context)!.darkMode),
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

  Widget _buildCounter(BuildContext context, WidgetRef ref) {
    final count = ref.watch(profileProvider).count;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        "${AppLocalizations.of(context)!.counter}: $count",
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../view_model/profile_view_model.dart';

/// Section for activity goals in the profile screen
class ActivityGoalsSection extends ConsumerWidget {
  const ActivityGoalsSection({super.key, required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
}

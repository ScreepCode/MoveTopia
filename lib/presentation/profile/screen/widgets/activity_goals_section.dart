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
    final l10n = AppLocalizations.of(context)!;
    final profileState = ref.watch(profileProvider);
    final stepsGoal = profileState.stepGoal;
    final dailyExerciseMinutes = profileState.dailyExerciseMinutesGoal;
    final weeklyExerciseMinutes = profileState.weeklyExerciseMinutesGoal;

    // Controller für Steps
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

    // Controller für tägliche Trainingsminuten
    TextEditingController dailyExerciseInputController =
        TextEditingController(text: dailyExerciseMinutes.toString());
    FocusNode dailyExerciseFocusNode = FocusNode();
    dailyExerciseFocusNode.addListener(() {
      if (!dailyExerciseFocusNode.hasFocus) {
        final minutes = int.tryParse(dailyExerciseInputController.text);
        if (minutes != null) {
          ref
              .read(profileProvider.notifier)
              .setDailyExerciseMinutesGoal(minutes);
        } else {
          dailyExerciseInputController.text = dailyExerciseMinutes.toString();
        }
      }
    });

    // Controller für wöchentliche Trainingsminuten
    TextEditingController weeklyExerciseInputController =
        TextEditingController(text: weeklyExerciseMinutes.toString());
    FocusNode weeklyExerciseFocusNode = FocusNode();
    weeklyExerciseFocusNode.addListener(() {
      if (!weeklyExerciseFocusNode.hasFocus) {
        final minutes = int.tryParse(weeklyExerciseInputController.text);
        if (minutes != null) {
          ref
              .read(profileProvider.notifier)
              .setWeeklyExerciseMinutesGoal(minutes);
        } else {
          weeklyExerciseInputController.text = weeklyExerciseMinutes.toString();
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
              Text(l10n.goal_activities_title,
                  style: Theme.of(context).textTheme.titleMedium),
              const Divider()
            ],
          ),
        ),
        // Schrittziel
        TextField(
          controller: stepsInputController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l10n.goal_steps_title,
            hintText: l10n.goal_steps_set_goal,
            border: const OutlineInputBorder(),
          ),
          focusNode: stepsFocusNode,
          onTapOutside: (context) {
            stepsFocusNode.unfocus();
          },
        ),
        const SizedBox(height: 16),
        // Tägliches Trainingsziel
        TextField(
          controller: dailyExerciseInputController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "${l10n.exercise_minutes_title} (${l10n.common_daily})",
            hintText: "${l10n.exercise_minutes_title} (${l10n.common_daily})",
            border: const OutlineInputBorder(),
            suffixText: l10n.common_minutes,
          ),
          focusNode: dailyExerciseFocusNode,
          onTapOutside: (context) {
            dailyExerciseFocusNode.unfocus();
          },
        ),
        const SizedBox(height: 16),
        // Wöchentliches Trainingsziel
        TextField(
          controller: weeklyExerciseInputController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "${l10n.exercise_minutes_title} (${l10n.common_weekly})",
            hintText: "${l10n.exercise_minutes_title} (${l10n.common_weekly})",
            border: const OutlineInputBorder(),
            suffixText: l10n.common_minutes,
          ),
          focusNode: weeklyExerciseFocusNode,
          onTapOutside: (context) {
            weeklyExerciseFocusNode.unfocus();
          },
        ),
      ],
    );
  }
}

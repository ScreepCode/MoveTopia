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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final profileState = ref.watch(profileProvider);
    final stepsGoal = profileState.stepGoal;
    final dailyExerciseMinutes = profileState.dailyExerciseMinutesGoal;
    final weeklyExerciseMinutes = profileState.weeklyExerciseMinutesGoal;

    // Textcontroller for steps goal
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

    // Textcontroller for daily exercise minutes
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

    // Textcontroller for weekly exercise minutes
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
                  style: theme.textTheme.titleMedium),
              const Divider()
            ],
          ),
        ),

        // Goal Input Cards
        _buildGoalCard(
          context,
          icon: Icons.directions_walk,
          title: l10n.goal_steps_title,
          controller: stepsInputController,
          focusNode: stepsFocusNode,
          suffix: "",
          color: theme.colorScheme.primary,
        ),

        const SizedBox(height: 16),

        _buildGoalCard(
          context,
          icon: Icons.timer,
          title: "${l10n.exercise_minutes_title} (${l10n.common_daily})",
          controller: dailyExerciseInputController,
          focusNode: dailyExerciseFocusNode,
          suffix: l10n.common_minutes,
          color: theme.colorScheme.secondary,
        ),

        const SizedBox(height: 16),

        _buildGoalCard(
          context,
          icon: Icons.calendar_month,
          title: "${l10n.exercise_minutes_title} (${l10n.common_weekly})",
          controller: weeklyExerciseInputController,
          focusNode: weeklyExerciseFocusNode,
          suffix: l10n.common_minutes,
          color: theme.colorScheme.tertiary,
        ),
      ],
    );
  }

  Widget _buildGoalCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String suffix,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline,
                          width: 1,
                        ),
                      ),
                      suffixText: suffix,
                    ),
                    onTapOutside: (_) => focusNode.unfocus(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

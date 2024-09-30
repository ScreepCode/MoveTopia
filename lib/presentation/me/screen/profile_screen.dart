import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:movetopia/presentation/me/view_model/profile_view_model.dart';

final logger = Logger('ProfileScreen');

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepsGoal = ref.watch(profileProvider).stepGoal;
    final count = ref.watch(profileProvider).count;
    final isDarkMode = ref.watch(profileProvider).isDarkMode;

    TextEditingController stepsInputController =
        TextEditingController(text: stepsGoal.toString());

    // This will update the value of stepGoal weather the user presses the enter key or taps outside the text field
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

    return Scaffold(
      body: Center(
        child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 16.0), // Add padding here
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Profile',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text("Activiy Goals:"),
                ),
                const Divider(),
                TextField(
                  controller: stepsInputController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Step Goal',
                      hintText: 'Enter your daily step goal',
                      border: OutlineInputBorder()),
                  focusNode: stepsFocusNode,
                  onTapOutside: (context) {
                    stepsFocusNode.unfocus();
                  },
                ),
                const SizedBox(
                  height: 32.0,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text("Settings:"),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  contentPadding: EdgeInsets.zero,
                  value: isDarkMode,
                  onChanged: (value) {
                    ref.read(profileProvider.notifier).setIsDarkMode(value);
                    logger.info('Change in Dropdown');
                  },
                ),
                const SizedBox(
                  height: 32.0,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text("For Fun:"),
                ),
                const Divider(),
                Text(
                  "Counter: $count",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            )),
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
}

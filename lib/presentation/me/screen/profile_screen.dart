import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/presentation/me/view_model/profile_view_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';

final logger = Logger('ProfileScreen');

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final stepsGoal = ref.watch(profileProvider)['stepGoal'];
    final count = ref.watch(profileProvider).count;
    final isDarkMode = ref.watch(profileProvider).isDarkMode;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              isDarkMode.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextButton(
              onPressed: () {
                context.go("/");
              },
              child: const Text('Go to Today'),
            ),
            DropdownButton<bool>(
              value: isDarkMode,
              items: const [
                DropdownMenuItem(
                  value: false,
                  child: Text('Hell'),
                ),
                DropdownMenuItem(
                  value: true,
                  child: Text('Dunkel'),
                ),
              ],
              onChanged: (value) {
                ref.read(profileProvider.notifier).setIsDarkMode(value!);
                logger.info('Change in Dropdown');
              },
            ),
          ],
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
}

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/domain/service/level_service.dart';

class UserLevelDisplay extends ConsumerWidget {
  const UserLevelDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final levelService = ref.watch(levelServiceProvider);

    return FutureBuilder(
      future: Future.wait([
        levelService.getCurrentLevel(),
        levelService.getCurrentEp(),
        levelService.getEpForNextLevel(),
        levelService.getProgressToNextLevel(),
        levelService.getEpRemainingForNextLevel(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
              child: Text(l10n.common_error(snapshot.error.toString())));
        }

        final data = snapshot.data!;
        final level = data[0] as int;
        final ep = data[1] as int;
        final nextLevelEp = data[2] as int;
        final progress = data[3] as double;
        final epRemaining = data[4] as int;

        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.user_level_title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          level.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.user_level_progress,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${l10n.user_level_ep}: $ep / $nextLevelEp'),
                    Text(l10n.user_level_needed_ep(epRemaining)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

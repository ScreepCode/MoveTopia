import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../provider/streak_provider.dart';
import '../routes.dart';
import '../streak/screen/streak_details_screen.dart';

class StreakCard extends ConsumerWidget {
  final bool isCompact;

  const StreakCard({super.key, this.isCompact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final streakCount = ref.watch(streakCountProvider);

    return Card(
      margin: isCompact
          ? null
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          context.go(fullStreakDetailsPath);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                Theme.of(context).colorScheme.primary.withOpacity(0.05),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: isCompact
                ? _buildCompactContent(context, streakCount, l10n)
                : _buildFullContent(context, streakCount, l10n),
          ),
        ),
      ),
    );
  }

  Widget _buildFullContent(BuildContext context, AsyncValue<int> streakCount,
      AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.streakTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Icon(
              Icons.local_fire_department,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.streakSubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
        ),
        const SizedBox(height: 20),
        streakCount.when(
          data: (count) => Row(
            children: [
              Text(
                l10n.streakCount(count),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  count > 0 ? '🔥' : '❄️',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text(
            'Error: $error',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactContent(BuildContext context, AsyncValue<int> streakCount,
      AppLocalizations l10n) {
    return Row(
      children: [
        Icon(
          Icons.local_fire_department,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.streakTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              streakCount.when(
                data: (count) => Text(
                  l10n.streakCount(count),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                loading: () => const SizedBox(
                  height: 12,
                  width: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (error, stack) => Text(
                  'Error',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: streakCount.maybeWhen(
            data: (count) => Text(
              count > 0 ? '🔥 $count' : '❄️ 0',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            orElse: () => const SizedBox(width: 20),
          ),
        ),
      ],
    );
  }
}

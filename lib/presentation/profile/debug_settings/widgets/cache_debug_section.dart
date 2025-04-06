import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/core/app_logger.dart';
import 'package:movetopia/presentation/profile/debug_settings/provider/debug_provider.dart';

class CacheDebugSection extends HookConsumerWidget {
  final ValueNotifier<bool> isLoading;
  final _logger = AppLogger.getLogger('CacheDebugSection');

  CacheDebugSection({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settingsDebugCacheTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.orange,
                    ),
              ),
              const Divider(color: Colors.orange),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: ElevatedButton.icon(
            onPressed: isLoading.value
                ? null
                : () async {
                    isLoading.value = true;
                    try {
                      await ref.read(clearCacheProvider)();
                      _logger.info('Cache erfolgreich gelöscht');

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.settingsDebugCacheCleared),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      _logger.severe('Fehler beim Löschen des Caches: $e');

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.settingsDebugCacheError('$e')),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } finally {
                      isLoading.value = false;
                    }
                  },
            icon: const Icon(Icons.delete_sweep, color: Colors.red),
            label: Text(l10n.settingsDebugCacheClear),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}

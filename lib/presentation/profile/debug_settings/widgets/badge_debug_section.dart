import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../provider/debug_provider.dart';

class BadgeDebugSection extends HookConsumerWidget {
  final ValueNotifier<bool> isLoading;

  const BadgeDebugSection({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selectedBadgeId = useState<int?>(null);
    final badgeStatus = useState<bool>(false);

    // Wir nutzen .autoDispose, um bei Änderungen die Liste neu zu laden
    final badgesData = ref.watch(allBadgesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titel
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settingsDebugBadgeTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.purple,
                    ),
              ),
              const Divider(color: Colors.purple),
            ],
          ),
        ),

        // Validate All Badges Button
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: ElevatedButton.icon(
            onPressed: isLoading.value
                ? null
                : () async {
                    isLoading.value = true;
                    try {
                      await ref.read(validateAllBadgesProvider)();
                      ref.invalidate(allBadgesProvider); // Liste neu laden
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text(l10n.settingsDebugBadgeValidateSuccess),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.settingsDebugBadgeError('$e')),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } finally {
                      isLoading.value = false;
                    }
                  },
            icon: const Icon(Icons.refresh, color: Colors.green),
            label: Text(l10n.settingsDebugBadgeValidate),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade50,
              foregroundColor: Colors.green,
            ),
          ),
        ),

        // Toggle Individual Badge Status
        badgesData.when(
          data: (badges) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.settingsDebugBadgeToggleTitle),
                const SizedBox(height: 8),

                // Badge Dropdown
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: l10n.settingsDebugBadgeSelect,
                    border: const OutlineInputBorder(),
                  ),
                  value: selectedBadgeId.value,
                  items: [
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text('---'),
                    ),
                    ...badges.map((badge) => DropdownMenuItem<int>(
                          value: badge['id'],
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  '${badge['name']} (${badge['category']})',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                badge['isAchieved']
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: badge['isAchieved']
                                    ? Colors.green
                                    : Colors.red,
                                size: 16,
                              ),
                            ],
                          ),
                        )),
                  ],
                  isExpanded: true,
                  isDense: true,
                  onChanged: (value) {
                    selectedBadgeId.value = value;
                    if (value != null) {
                      // Korrektes Finden der Badge ohne orElse
                      for (final badge in badges) {
                        if (badge['id'] == value) {
                          badgeStatus.value = badge['isAchieved'];
                          break;
                        }
                      }
                    }
                  },
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Status toggle
                    ChoiceChip(
                      label: Text(badgeStatus.value
                          ? l10n.settingsDebugBadgeStatusDone
                          : l10n.settingsDebugBadgeStatusNotDone),
                      selected: badgeStatus.value,
                      onSelected: selectedBadgeId.value == null
                          ? null
                          : (newValue) {
                              badgeStatus.value = newValue;
                            },
                      selectedColor: Colors.green.shade100,
                    ),

                    const SizedBox(width: 16),

                    // Apply button
                    ElevatedButton(
                      onPressed: selectedBadgeId.value == null ||
                              isLoading.value
                          ? null
                          : () async {
                              isLoading.value = true;
                              try {
                                await ref.read(toggleBadgeStatusProvider)(
                                    selectedBadgeId.value!, badgeStatus.value);
                                // Liste nach Änderung aktualisieren
                                ref.invalidate(allBadgesProvider);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          l10n.settingsDebugBadgeToggleSuccess),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          l10n.settingsDebugBadgeError('$e')),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } finally {
                                isLoading.value = false;
                              }
                            },
                      child: Text(l10n.settingsDebugBadgeApply),
                    ),
                  ],
                )
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Text(l10n.settingsDebugBadgeLoadError),
        ),

        // Reset Badges Button
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: ElevatedButton.icon(
            onPressed: isLoading.value
                ? null
                : () async {
                    isLoading.value = true;
                    try {
                      await ref.read(resetBadgesProvider)();
                      // Liste nach Reset aktualisieren
                      ref.invalidate(allBadgesProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.settingsDebugBadgeResetSuccess),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.settingsDebugBadgeError('$e')),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } finally {
                      isLoading.value = false;
                    }
                  },
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            label: Text(l10n.settingsDebugBadgeReset),
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

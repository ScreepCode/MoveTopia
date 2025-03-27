import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../provider/debug_provider.dart';

class DebugSection extends HookConsumerWidget {
  const DebugSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDebugBuild = ref.watch(isDebugBuildProvider);
    final daysController = useTextEditingController(text: '7');
    final selectedDate = useState<DateTime>(DateTime.now());
    final isLoading = useState<bool>(false);

    // Formatierung für Datumsauswahl
    final dateFormat = DateFormat('dd.MM.yyyy');

    return isDebugBuild.when(
      data: (isDebug) {
        if (!isDebug) {
          return const SizedBox
              .shrink(); // Nicht anzeigen, wenn kein Debug-Build
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.streakDebugTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.red,
                        ),
                  ),
                  const Divider(color: Colors.red),
                ],
              ),
            ),

            // Streak für X vergangene Tage simulieren
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: daysController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.streakDebugDays,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isLoading.value
                        ? null
                        : () async {
                            final days = int.tryParse(daysController.text);
                            if (days != null && days > 0) {
                              isLoading.value = true;
                              try {
                                await ref.read(
                                    simulateStreakForPastDaysProvider)(days);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          l10n.streakDebugDaysSimulated(days)),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } finally {
                                isLoading.value = false;
                              }
                            }
                          },
                    child: Text(l10n.streakDebugSimulatePast),
                  ),
                ],
              ),
            ),

            // Bestimmtes Datum als erreicht markieren
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate.value,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          selectedDate.value = picked;
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: l10n.streakDebugDate,
                          border: const OutlineInputBorder(),
                        ),
                        child: Text(dateFormat.format(selectedDate.value)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isLoading.value
                        ? null
                        : () async {
                            isLoading.value = true;
                            try {
                              await ref.read(simulateStreakForDateProvider)(
                                  selectedDate.value);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.streakDebugDateMarked(
                                        dateFormat.format(selectedDate.value))),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } finally {
                              isLoading.value = false;
                            }
                          },
                    child: Text(l10n.streakDebugMarkButton),
                  ),
                ],
              ),
            ),

            // Streak zurücksetzen
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton.icon(
                onPressed: isLoading.value
                    ? null
                    : () async {
                        isLoading.value = true;
                        try {
                          await ref.read(resetStreakProvider)();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.streakDebugResetSuccess),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        } finally {
                          isLoading.value = false;
                        }
                      },
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: Text(l10n.streakDebugReset),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

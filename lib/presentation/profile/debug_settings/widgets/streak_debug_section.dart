import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../presentation/challenges/provider/streak_provider.dart';
import '../provider/debug_provider.dart';

/// Widget für die Streak-Debugging-Funktionen
class StreakDebugSection extends HookConsumerWidget {
  final ValueNotifier<bool> isLoading;

  const StreakDebugSection({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final daysController = useTextEditingController(text: '7');
    final selectedDate = useState<DateTime>(DateTime.now());
    final dateFormat = DateFormat('dd.MM.yyyy');

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
                l10n.settingsDebugStreakTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.red,
                    ),
              ),
              const Divider(color: Colors.red),
            ],
          ),
        ),

        // Streak aus echten Health-Daten neu laden
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: ElevatedButton.icon(
            onPressed: isLoading.value
                ? null
                : () async {
                    isLoading.value = true;
                    try {
                      await ref.read(refreshStreakFromHealthDataProvider)();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Streak-Daten aus Health-Daten neu geladen'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Fehler beim Laden: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } finally {
                      isLoading.value = false;
                    }
                  },
            icon: const Icon(Icons.refresh, color: Colors.green),
            label: const Text('Echte Health-Daten laden'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade50,
              foregroundColor: Colors.green,
            ),
          ),
        ),

        // Streak für X vergangene Tage simulieren
        _buildPastDaysSimulator(context, ref, daysController, l10n),

        // Bestimmtes Datum als erreicht markieren
        _buildDateSimulator(context, ref, selectedDate, dateFormat, l10n),

        // Streak zurücksetzen
        _buildResetButton(context, ref, l10n),
      ],
    );
  }

  // Hilfsmethode für die Vergangenheitssimulation
  Widget _buildPastDaysSimulator(
    BuildContext context,
    WidgetRef ref,
    TextEditingController daysController,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: daysController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.settingsDebugStreakDays,
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
                        await ref.read(simulateStreakForPastDaysProvider)(days);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  l10n.settingsDebugStreakDaysSimulated(days)),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } finally {
                        isLoading.value = false;
                      }
                    }
                  },
            child: Text(l10n.settingsDebugStreakSimulatePast),
          ),
        ],
      ),
    );
  }

  // Hilfsmethode für die Datumsauswahl-Simulation
  Widget _buildDateSimulator(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<DateTime> selectedDate,
    DateFormat dateFormat,
    AppLocalizations l10n,
  ) {
    return Padding(
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
                  labelText: l10n.settingsDebugStreakDate,
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
                            content: Text(l10n.settingsDebugStreakDateMarked(
                                dateFormat.format(selectedDate.value))),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } finally {
                      isLoading.value = false;
                    }
                  },
            child: Text(l10n.settingsDebugStreakMarkButton),
          ),
        ],
      ),
    );
  }

  // Hilfsmethode für den Reset-Button
  Widget _buildResetButton(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    return Padding(
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
                        content: Text(l10n.settingsDebugStreakResetSuccess),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                } finally {
                  isLoading.value = false;
                }
              },
        icon: const Icon(Icons.delete_forever, color: Colors.red),
        label: Text(l10n.settingsDebugStreakReset),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
        ),
      ),
    );
  }
}

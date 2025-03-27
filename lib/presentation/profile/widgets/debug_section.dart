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
    final isLoading = useState<bool>(false);

    return isDebugBuild.when(
      data: (isDebug) {
        if (!isDebug) {
          return const SizedBox
              .shrink(); // Nicht anzeigen, wenn kein Debug-Build
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App-Daten Sektion
            const AppDatesSection(),

            const SizedBox(height: 16),

            // Streak Debugging Sektion
            StreakDebugSection(isLoading: isLoading),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Widget zur Anzeige und Bearbeitung der App-Datumsangaben (Installationsdatum & Last Updated)
class AppDatesSection extends HookConsumerWidget {
  const AppDatesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installDate = useState<DateTime>(DateTime.now());
    final lastOpenedDate = useState<DateTime>(DateTime.now());
    final isLoading = useState<bool>(false);
    final dateFormat = DateFormat('dd.MM.yyyy');

    // Installation und Last Updated Daten laden
    final installationDateAsync = ref.watch(installationDateProvider);
    final lastOpenedDateAsync = ref.watch(lastOpenedDateProvider);

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
                'App-Daten (Installationsdatum & Last Updated)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.blue,
                    ),
              ),
              const Divider(color: Colors.blue),
            ],
          ),
        ),

        // Installationsdatum-Widget
        _buildDateSection(
          context: context,
          asyncValue: installationDateAsync,
          dateState: installDate,
          dateFormat: dateFormat,
          isLoading: isLoading,
          title: 'Installationsdatum',
          labelText: 'Neues Installationsdatum',
          updateAction: (date) async {
            isLoading.value = true;
            try {
              await ref.read(updateInstallationDateProvider)(date);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Installationsdatum aktualisiert'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } finally {
              isLoading.value = false;
            }
          },
        ),

        // Last Updated Datum-Widget
        _buildDateSection(
          context: context,
          asyncValue: lastOpenedDateAsync,
          dateState: lastOpenedDate,
          dateFormat: dateFormat,
          isLoading: isLoading,
          title: 'Letztes Aktualisierungsdatum',
          labelText: 'Neues Last Updated Datum',
          updateAction: (date) async {
            isLoading.value = true;
            try {
              await ref.read(updateLastOpenedDateProvider)(date);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Last Updated Datum aktualisiert'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } finally {
              isLoading.value = false;
            }
          },
        ),
      ],
    );
  }

  // Hilfsmethode zum Erstellen einer Datums-Sektion
  Widget _buildDateSection({
    required BuildContext context,
    required AsyncValue<DateTime> asyncValue,
    required ValueNotifier<DateTime> dateState,
    required DateFormat dateFormat,
    required ValueNotifier<bool> isLoading,
    required String title,
    required String labelText,
    required Future<void> Function(DateTime) updateAction,
  }) {
    return asyncValue.when(
      data: (date) {
        // Initialisiere den State nur einmal
        if (dateState.value == DateTime.now()) {
          dateState.value = date;
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Zeige das aktuelle Datum
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('$title: ${dateFormat.format(date)}'),
            ),

            // Möglichkeit zum Ändern des Datums
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: dateState.value,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          dateState.value = picked;
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: labelText,
                          border: const OutlineInputBorder(),
                        ),
                        child: Text(dateFormat.format(dateState.value)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isLoading.value
                        ? null
                        : () => updateAction(dateState.value),
                    child: const Text('Aktualisieren'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Text('Fehler beim Laden: $title'),
    );
  }
}

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

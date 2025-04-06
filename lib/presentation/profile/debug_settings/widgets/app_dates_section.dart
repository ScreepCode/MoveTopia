import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../provider/debug_provider.dart';

/// Widget zur Anzeige und Bearbeitung der App-Datumsangaben (Installationsdatum & Last Updated)
class AppDatesSection extends HookConsumerWidget {
  const AppDatesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
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
                l10n.settingsDebugAppDatesSectionTitle,
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
          l10n: l10n,
          asyncValue: installationDateAsync,
          dateState: installDate,
          dateFormat: dateFormat,
          isLoading: isLoading,
          title: l10n.settingsDebugInstallationDate,
          labelText: l10n.settingsDebugNewInstallationDate,
          updateAction: (date) async {
            isLoading.value = true;
            try {
              await ref.read(updateInstallationDateProvider)(date);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.settingsDebugDateUpdated),
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
          l10n: l10n,
          asyncValue: lastOpenedDateAsync,
          dateState: lastOpenedDate,
          dateFormat: dateFormat,
          isLoading: isLoading,
          title: l10n.settingsDebugLastUpdatedDate,
          labelText: l10n.settingsDebugNewLastUpdatedDate,
          updateAction: (date) async {
            isLoading.value = true;
            try {
              await ref.read(updateLastOpenedDateProvider)(date);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.settingsDebugDateUpdated),
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
    required AppLocalizations l10n,
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
                    child: Text(l10n.settingsDebugUpdateButton),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Text(l10n.settingsDebugErrorLoadingDate(title)),
    );
  }
}

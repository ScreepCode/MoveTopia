import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/presentation/today/widgets/survey_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Debug Sektion for User Survey
class SurveyDebugSection extends ConsumerWidget {
  final ValueNotifier<bool> isLoading;

  const SurveyDebugSection({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Survey Debug',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, bool>>(
              future: _getSurveyStatus(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final status =
                    snapshot.data ?? {'dismissed': false, 'completed': false};
                final dismissed = status['dismissed'] ?? false;
                final completed = status['completed'] ?? false;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Aktueller Status:',
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    _buildStatusChip(context, 'Dismissed', dismissed,
                        theme.colorScheme.error),
                    const SizedBox(height: 4),
                    _buildStatusChip(context, 'Completed', completed,
                        theme.colorScheme.primary),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reset Status'),
                          onPressed: () => _resetSurveyStatus(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Mark Completed'),
                          onPressed: () => _markSurveyCompleted(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary,
                            foregroundColor: theme.colorScheme.onSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.close),
                          label: const Text('Mark Dismissed'),
                          onPressed: () => _markSurveyDismissed(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.error,
                            foregroundColor: theme.colorScheme.onError,
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.date_range),
                          label: const Text('Set to Today'),
                          onPressed: () => _setStartDateToToday(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.tertiary,
                            foregroundColor: theme.colorScheme.onTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Creates a status chip with a label and value
  Widget _buildStatusChip(
      BuildContext context, String label, bool value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: value ? color : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: value ? Colors.white : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(value ? 'Ja' : 'Nein'),
      ],
    );
  }

  /// Reads the survey status from SharedPreferences
  Future<Map<String, bool>> _getSurveyStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final dismissed =
        prefs.getBool(SurveyConstants.prefKeySurveyDismissed) ?? false;
    final completed =
        prefs.getBool(SurveyConstants.prefKeySurveyCompleted) ?? false;

    return {
      'dismissed': dismissed,
      'completed': completed,
    };
  }

  /// Resets the survey status in SharedPreferences
  Future<void> _resetSurveyStatus(BuildContext context) async {
    isLoading.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(SurveyConstants.prefKeySurveyDismissed);
      await prefs.remove(SurveyConstants.prefKeySurveyCompleted);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Survey-Status zurückgesetzt')),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Marks the survey as completed
  Future<void> _markSurveyCompleted(BuildContext context) async {
    isLoading.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(SurveyConstants.prefKeySurveyCompleted, true);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Umfrage als abgeschlossen markiert')),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Marks the survey as dismissed
  Future<void> _markSurveyDismissed(BuildContext context) async {
    isLoading.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(SurveyConstants.prefKeySurveyDismissed, true);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Umfrage als verworfen markiert')),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Set the start date to today
  Future<void> _setStartDateToToday(BuildContext context) async {
    isLoading.value = true;

    try {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'StartDate ist ein static final Feld und kann zur Laufzeit nicht geändert werden. Bitte ändere den Code direkt.')),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}

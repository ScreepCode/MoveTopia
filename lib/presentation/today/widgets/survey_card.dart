import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:movetopia/presentation/common/widgets/generic_card.dart';
import 'package:movetopia/presentation/today/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Constants for the survey feature
class SurveyConstants {
  /// The end date for the survey
  static final DateTime surveyEndDate = DateTime(2024, 5, 19);

  /// The survey URL
  static const String surveyUrl = 'https://forms.gle/QY8HnRF2LFnQqRJ18';

  /// Keys for shared preferences
  static const String prefKeySurveyDismissed = 'survey_dismissed';
  static const String prefKeySurveyCompleted = 'survey_completed';
}

/// A card that promotes the user survey
class SurveyCard extends StatelessWidget {
  /// Callback, if the card is dismissed
  final VoidCallback onDismiss;

  const SurveyCard({
    super.key,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return GenericCard(
      title: l10n.survey_card_title,
      subtitles: [l10n.survey_card_subtitle],
      iconData: Icons.assignment,
      color: theme.colorScheme.tertiary,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.survey_card_description,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  _dismissSurvey(context, temporarily: true);
                  onDismiss();
                },
                child: Text(l10n.survey_card_remind_later),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _showSurveyOptions(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.tertiary,
                  foregroundColor: theme.colorScheme.onTertiary,
                ),
                child: Text(l10n.survey_card_take_survey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Shows a dialog with options to open the survey
  Future<void> _showSurveyOptions(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.survey_dialog_title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.survey_dialog_content),
            const SizedBox(height: 16),
            _dialogOptionButton(
              context,
              icon: Icons.web,
              label: l10n.survey_dialog_open_in_app,
              onTap: () {
                Navigator.of(context).pop();
                _openSurveyInWebView(context);
              },
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            _dialogOptionButton(
              context,
              icon: Icons.open_in_browser,
              label: l10n.survey_dialog_open_externally,
              onTap: () {
                Navigator.of(context).pop();
                _openSurveyExternally(context);
              },
              color: theme.colorScheme.tertiary,
            ),
            const SizedBox(height: 8),
            _dialogOptionButton(
              context,
              icon: Icons.check_circle_outline,
              label: l10n.survey_dialog_already_completed,
              onTap: () {
                Navigator.of(context).pop();
                _markAsCompleted(context);
              },
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(height: 8),
            _dialogOptionButton(
              context,
              icon: Icons.close,
              label: l10n.survey_dialog_not_interested,
              onTap: () {
                Navigator.of(context).pop();
                _dismissSurvey(context, temporarily: false);
                onDismiss();
              },
              color: theme.colorScheme.error,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.common_close),
          ),
        ],
      ),
    );
  }

  /// Helper to create a dialog option button
  Widget _dialogOptionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Opens the survey in an in-app WebView
  Future<void> _openSurveyInWebView(BuildContext context) async {
    if (context.mounted) {
      context.push(fullSurveyWebViewPath, extra: SurveyConstants.surveyUrl);

      Future.delayed(const Duration(milliseconds: 300), () {
        if (context.mounted) {
          onDismiss();
        }
      });
    }
  }

  /// Opens the survey in an external browser
  Future<void> _openSurveyExternally(BuildContext context) async {
    final Uri url = Uri.parse(SurveyConstants.surveyUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);

      if (context.mounted) {
        await Future.delayed(const Duration(seconds: 1));
        await _showCompletionDialog(context);
      }
      onDismiss();
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.survey_error_opening_url),
          ),
        );
      }
    }
  }

  /// Shows a dialog to confirm if the survey is completed
  Future<void> _showCompletionDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final completedSurvey = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.survey_completed_question),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle),
              label: Text(l10n.survey_completed_yes),
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(Icons.close),
              label: Text(l10n.survey_completed_no),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );

    // Only mark as completed if the user confirms
    if (completedSurvey == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(SurveyConstants.prefKeySurveyCompleted, true);
    }
  }

  /// Marks the survey as completed
  Future<void> _markAsCompleted(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SurveyConstants.prefKeySurveyCompleted, true);
    onDismiss();
  }

  /// Dismisses the survey card
  Future<void> _dismissSurvey(BuildContext context,
      {required bool temporarily}) async {
    final prefs = await SharedPreferences.getInstance();

    if (temporarily) {
    } else {
      await prefs.setBool(SurveyConstants.prefKeySurveyDismissed, true);
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }
}

/// Helper functions to check if the survey should be shown
class SurveyHelper {
  /// Checks if the current date is before or at the survey end date
  static bool isSurveyAvailable() {
    final now = DateTime.now();
    // Prüfe nur, ob das aktuelle Datum vor dem Enddatum liegt
    return now.isBefore(SurveyConstants.surveyEndDate) ||
        now.isAtSameMomentAs(SurveyConstants.surveyEndDate);
  }

  /// Checks if the survey should be shown based on preferences and date
  static Future<bool> shouldShowSurvey() async {
    // Check date first
    if (!isSurveyAvailable()) {
      return false;
    }

    // Check preferences
    final prefs = await SharedPreferences.getInstance();
    final isDismissed =
        prefs.getBool(SurveyConstants.prefKeySurveyDismissed) ?? false;
    final isCompleted =
        prefs.getBool(SurveyConstants.prefKeySurveyCompleted) ?? false;

    // Show if not dismissed and not completed
    return !isDismissed && !isCompleted;
  }
}

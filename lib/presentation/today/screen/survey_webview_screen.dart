import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../widgets/survey_card.dart';

/// A screen that displays a survey in a WebView
class SurveyWebViewScreen extends StatefulWidget {
  /// The URL of the survey
  final String surveyUrl;

  /// Creates a new [SurveyWebViewScreen]
  const SurveyWebViewScreen({super.key, required this.surveyUrl});

  @override
  State<SurveyWebViewScreen> createState() => _SurveyWebViewScreenState();
}

class _SurveyWebViewScreenState extends State<SurveyWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.surveyUrl));
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

    if (completedSurvey == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(SurveyConstants.prefKeySurveyCompleted, true);
    }
  }

  /// Opens the survey URL in the default browser
  Future<void> _openInBrowser() async {
    final Uri url = Uri.parse(widget.surveyUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.survey_error_opening_url),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.survey_webview_title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            // Dialog anzeigen, bevor die Seite verlassen wird
            await _showCompletionDialog(context);
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: _openInBrowser,
            tooltip: l10n.survey_dialog_open_externally,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
            tooltip: l10n.common_refresh,
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

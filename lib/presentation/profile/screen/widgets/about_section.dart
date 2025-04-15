import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/core/constants.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../debug_settings/provider/debug_provider.dart';
import '../../routes.dart';

/// Section for the about page in the profile screen
class AboutSection extends ConsumerWidget {
  const AboutSection({
    super.key,
    required this.ref,
    required this.packageInfoFuture,
  });

  final WidgetRef ref;
  final Future<PackageInfo> packageInfoFuture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final hiddenLogAccess = ref.watch(hiddenLogAccessProvider);
    final hiddenLogAccessNotifier = ref.watch(hiddenLogAccessProvider.notifier);

    return FutureBuilder<PackageInfo>(
      future: packageInfoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text(l10n.common_error_version);
        } else {
          final packageInfo = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.common_about,
                    style: Theme.of(context).textTheme.titleMedium),
                const Divider(),
                // App Information
                const AboutAppTile(),
                // Developer Information
                const AboutDeveloperTile(),
                // Known Issues
                const KnownIssuesTile(),
                // Community Discussions
                const CommunityDiscussionsTile(),
                // Version Information (with hidden log access)
                VersionInfoTile(
                  packageInfo: packageInfo,
                  hiddenLogAccessNotifier: hiddenLogAccessNotifier,
                ),
                // Early Version Disclaimer
                const SizedBox(height: 8),
                const EarlyVersionDisclaimer(),
              ],
            ),
          );
        }
      },
    );
  }
}

/// Tile for App-Information
class AboutAppTile extends StatelessWidget {
  const AboutAppTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.info_outline),
      title: Text(l10n.about_app_header),
      subtitle: Text(l10n.about_app_text),
      onTap: () => _showAboutDialog(context),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.about_app_dialog_header),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.about_app_dialog_text_1),
              const SizedBox(height: 8),
              Text(l10n.about_app_dialog_text_2),
            ],
          ),
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
}

/// Tile for Developer-Information
class AboutDeveloperTile extends StatelessWidget {
  const AboutDeveloperTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.people_outline),
      title: Text(l10n.about_dev_header),
      subtitle: Text(l10n.about_dev_text),
      onTap: () => _showDeveloperDialog(context),
    );
  }

  void _showDeveloperDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.about_dev_dialog_header),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.about_dev_dialog_text_1),
            const SizedBox(height: 8),
            Text(l10n.about_dev_dialog_text_2),
            const SizedBox(height: 16),
            const WebsiteLink(url: AppConstants.niklasWebsiteUrl),
            const SizedBox(height: 8),
            const WebsiteLink(url: AppConstants.joshuaWebsiteUrl),
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
}

/// Tile for known issues
class KnownIssuesTile extends StatelessWidget {
  const KnownIssuesTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.bug_report_outlined),
      title: Text(l10n.about_issues_header),
      subtitle: Text(l10n.about_issues_text),
      trailing: const Icon(Icons.open_in_new, size: 16),
      onTap: () async {
        final Uri url = Uri.parse(AppConstants.githubIssuesUrl);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not open ${url.toString()}'),
              ),
            );
          }
        }
      },
    );
  }
}

/// Tile for Community Discussions
class CommunityDiscussionsTile extends StatelessWidget {
  const CommunityDiscussionsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.forum_outlined),
      title: Text(l10n.about_community_header),
      subtitle: Text(l10n.about_community_text),
      trailing: const Icon(Icons.open_in_new, size: 16),
      onTap: () async {
        final Uri url = Uri.parse(AppConstants.githubDiscussionsUrl);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not open ${url.toString()}'),
              ),
            );
          }
        }
      },
    );
  }
}

/// Tile for Version Information
class VersionInfoTile extends StatelessWidget {
  const VersionInfoTile({
    super.key,
    required this.packageInfo,
    required this.hiddenLogAccessNotifier,
  });

  final PackageInfo packageInfo;
  final HiddenLogAccessNotifier hiddenLogAccessNotifier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Future<void> copyVersionToClipboard() async {
      final data = ClipboardData(text: packageInfo.version);
      await Clipboard.setData(data);
      if (context.mounted) {
        // Only show snackbar if Android API Level is higher than 31
        final deviceInfo = DeviceInfoPlugin();
        var showSnackbar = true;
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          // Only show snackbar if Android API Level is higher than 31 meaning Android 12
          showSnackbar = androidInfo.version.sdkInt < 32;
        }
        if (showSnackbar) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.common_version_copied)),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.common_version_copied),
            ),
          );
        }
      }
    }

    return InkWell(
      onTap: () {
        hiddenLogAccessNotifier.incrementClickCount();
        if (hiddenLogAccessNotifier.isLogAccessEnabled) {
          hiddenLogAccessNotifier.resetClickCount();
          HapticFeedback.mediumImpact();
          context.go('$profilePath/$profileLoggingPath');
        }
      },
      onLongPress: () {
        copyVersionToClipboard();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          "${l10n.common_version}: ${packageInfo.version}",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

/// Early Version Disclaimer
class EarlyVersionDisclaimer extends StatelessWidget {
  const EarlyVersionDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: () async {
        final Uri url = Uri.parse(AppConstants.githubIssuesUrl);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not open ${url.toString()}'),
              ),
            );
          }
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.about_app_disclaimer,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
            Icon(
              Icons.open_in_new,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget for a styled and working website link
class WebsiteLink extends StatelessWidget {
  const WebsiteLink({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Row(
        children: [
          const Icon(Icons.open_in_new, size: 16),
          const SizedBox(width: 8),
          Text(
            url.removeURLPrefix(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}

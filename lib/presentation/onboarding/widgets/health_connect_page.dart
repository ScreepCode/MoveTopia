import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/core/constants.dart';
import 'package:movetopia/presentation/common/app_assets.dart';
import 'package:movetopia/presentation/onboarding/providers/health_connect_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HealthConnectPage extends ConsumerWidget {
  const HealthConnectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final healthConnectState = ref.watch(healthConnectProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: theme.scaffoldBackgroundColor,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Health Connect App Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                AppAssets.healthConnectIcon,
                width: 64,
                height: 64,
                color: theme.colorScheme.primary,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback icon if asset not found
                  return Icon(
                    Icons.health_and_safety,
                    size: 64,
                    color: theme.colorScheme.primary,
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            Text(
              l10n.onboarding_health_connect_title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Text(
              l10n.onboarding_health_connect_description,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Health Connect Installation Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          healthConnectState.isHealthConnectInstalled
                              ? Icons.check_circle
                              : Icons.info_outline,
                          color: healthConnectState.isHealthConnectInstalled
                              ? theme.colorScheme.primary
                              : theme.colorScheme.secondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                healthConnectState.isHealthConnectInstalled
                                    ? l10n
                                        .onboarding_health_connect_installed_title
                                    : l10n
                                        .onboarding_health_connect_install_title,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: healthConnectState
                                          .isHealthConnectInstalled
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                healthConnectState.isHealthConnectInstalled
                                    ? l10n
                                        .onboarding_health_connect_installed_description
                                    : l10n
                                        .onboarding_health_connect_install_description,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (!healthConnectState.isHealthConnectInstalled)
                      FilledButton.icon(
                        onPressed: () async {
                          try {
                            await ref
                                .read(healthConnectProvider.notifier)
                                .installHealthConnect();

                            // Refresh the status after a short delay
                            await Future.delayed(const Duration(seconds: 2));
                            if (context.mounted) {
                              ref
                                  .read(healthConnectProvider.notifier)
                                  .refresh();
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      l10n.error_installing_health_connect),
                                  backgroundColor: theme.colorScheme.error,
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.health_and_safety),
                        label:
                            Text(l10n.onboarding_health_connect_install_button),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Fitness Apps Configuration Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.settings,
                          color: theme.colorScheme.secondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.onboarding_health_connect_config_title,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.onboarding_health_connect_config_description,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final Uri url =
                            Uri.parse(AppConstants.healthConnectConfigUrl);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url,
                              mode: LaunchMode.externalApplication);
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.error_opening_url),
                                backgroundColor: theme.colorScheme.error,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.help_outline),
                      label: Text(l10n.onboarding_health_connect_config_button),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

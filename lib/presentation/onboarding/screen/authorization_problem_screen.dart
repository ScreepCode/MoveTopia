import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/presentation/onboarding/providers/onboarding_provider.dart';
import 'package:movetopia/presentation/onboarding/routes.dart';

class AuthorizationProblemScreen extends HookConsumerWidget {
  const AuthorizationProblemScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 80,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.common_access_health,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.permissions_required_for_app_functionality,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () {
                  ref.read(onboardingProvider.notifier).resetOnboarding();
                  context.go(onboardingPath);
                },
                icon: const Icon(Icons.settings),
                label: Text(l10n.restart_onboarding),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

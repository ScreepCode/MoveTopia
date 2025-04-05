import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/presentation/onboarding/providers/onboarding_provider.dart';

import 'health_authorized_view_model.dart';

class AuthorizationWrapper extends HookConsumerWidget {
  final Widget child;

  const AuthorizationWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(healthViewModelProvider);
    final hasCompletedOnboarding = ref.watch(hasCompletedOnboardingProvider);
    final theme = Theme.of(context);

    final l10n = AppLocalizations.of(context);

    final String healthAccessMessage = l10n?.common_access_health ??
        "Bitte erlaube Zugriff auf deine Gesundheitsdaten";

    return hasCompletedOnboarding.when(
      data: (isCompleted) {
        if (!isCompleted) {
          return child;
        }

        if (authState == HealthAuthViewModelState.notAuthorized) {
          return MaterialApp(
            theme: theme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      "Berechtigungen werden überprüft...",
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (authState ==
                HealthAuthViewModelState.authorizationNotGranted ||
            authState == HealthAuthViewModelState.error) {
          return MaterialApp(
            theme: theme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
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
                        healthAccessMessage,
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Die App benötigt Zugriff auf deine Gesundheitsdaten, um korrekt zu funktionieren.",
                        style: theme.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      FilledButton.icon(
                        onPressed: () {
                          ref
                              .read(onboardingProvider.notifier)
                              .resetOnboarding();
                          context.go('/onboarding');
                        },
                        icon: const Icon(Icons.settings),
                        label: const Text("Berechtigungen erteilen"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else if (authState == HealthAuthViewModelState.authorized) {
          return child;
        } else {
          return MaterialApp(
            theme: theme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
      },
      loading: () => MaterialApp(
        theme: theme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, stack) => MaterialApp(
        theme: theme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: Text("Fehler beim Laden des Onboarding-Status: $error"),
          ),
        ),
      ),
    );
  }
}

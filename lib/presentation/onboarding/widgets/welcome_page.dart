import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:movetopia/presentation/common/app_assets.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      color: theme.scaffoldBackgroundColor,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // App logo
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                AppAssets.appIcon,
                height: 120,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: 48),

            // Welcome title
            Text(
              l10n.onboarding_welcome_title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Welcome description
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.onboarding_welcome_description,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 48),

            // Animated icon row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAnimatedIcon(
                    context, Icons.directions_run, l10n.navigation_activities),
                _buildAnimatedIcon(context, Icons.emoji_events,
                    l10n.challenges_achievements_title),
                _buildAnimatedIcon(context, Icons.show_chart, l10n.stats_title),
              ],
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 32,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

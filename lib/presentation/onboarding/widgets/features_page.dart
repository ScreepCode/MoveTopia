import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: theme.scaffoldBackgroundColor,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.stars,
                size: 64,
                color: theme.colorScheme.secondary,
              ),
            ),

            const SizedBox(height: 40),

            Text(
              l10n.onboarding_features_title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Challenges Feature
            _buildFeatureItem(
              context,
              Icons.emoji_events,
              l10n.onboarding_feature_challenges_title,
              l10n.onboarding_feature_challenges_description,
              theme.colorScheme.primary,
            ),

            const SizedBox(height: 24),

            // Activity Tracking Feature
            _buildFeatureItem(
              context,
              Icons.directions_run,
              l10n.onboarding_feature_tracking_title,
              l10n.onboarding_feature_tracking_description,
              theme.colorScheme.secondary,
            ),

            const SizedBox(height: 24),

            // Stats und Analysis Feature
            _buildFeatureItem(
              context,
              Icons.insert_chart,
              l10n.onboarding_feature_stats_title,
              l10n.onboarding_feature_stats_description,
              theme.colorScheme.tertiary,
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    Color accentColor,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 32,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

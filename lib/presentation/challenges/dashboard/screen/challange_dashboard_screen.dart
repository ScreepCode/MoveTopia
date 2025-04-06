import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/data/model/badge.dart';
import 'package:movetopia/presentation/challenges/badgeLists/viewmodel/badge_lists_view_model.dart';
import 'package:movetopia/presentation/challenges/dashboard/widgets/category_highlight_widget.dart';
import 'package:movetopia/presentation/challenges/provider/badge_lists_provider.dart';
import 'package:movetopia/presentation/challenges/routes.dart';
import 'package:movetopia/presentation/challenges/widgets/streak_card.dart';

import '../../widgets/user_level_card.dart';

class ChallengeDashboardScreen extends ConsumerStatefulWidget {
  const ChallengeDashboardScreen({super.key});

  @override
  ConsumerState<ChallengeDashboardScreen> createState() =>
      _ChallengeDashboardScreenState();
}

class _ChallengeDashboardScreenState
    extends ConsumerState<ChallengeDashboardScreen> {
  bool _isRefreshing = false;

  Future<void> _refreshData() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      // Badges neu prüfen und aktualisieren
      await ref.read(badgeListsViewModelProvider.notifier).refreshBadges();
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.challenges_dashboard_title),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _buildContent(context, ref, l10n),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const UserLevelDisplay(),

          // Streak Card
          const StreakCard(isCompact: false),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              l10n.challenges_achievements_title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),

          // Daily Steps Category Highlight
          CategoryHighlightWidget(
            category: AchievementBadgeCategory.dailySteps,
            categoryName: l10n.badge_daily_steps_category,
            categoryProgress: todayStepsProvider,
            onSeeAll: () => _navigateToBadgeList(context,
                category: AchievementBadgeCategory.dailySteps),
          ),

          const SizedBox(height: 16),

          // Total Steps Category Highlight
          CategoryHighlightWidget(
            category: AchievementBadgeCategory.totalSteps,
            categoryName: l10n.badge_total_steps_category,
            categoryProgress: totalStepsProvider,
            onSeeAll: () => _navigateToBadgeList(context,
                category: AchievementBadgeCategory.totalSteps),
          ),

          const SizedBox(height: 16),

          // Cycling Distance Category Highlight
          CategoryHighlightWidget(
            category: AchievementBadgeCategory.totalCyclingDistance,
            categoryName: l10n.badge_cycling_category,
            categoryProgress: totalCyclingProvider,
            onSeeAll: () => _navigateToBadgeList(context,
                category: AchievementBadgeCategory.totalCyclingDistance),
          ),

          const SizedBox(height: 32),

          // Button to see all badges
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _navigateToBadgeList(context),
              icon: const Icon(Icons.emoji_events),
              label: Text(l10n.challenges_see_all_badges),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _navigateToBadgeList(BuildContext context,
      {AchievementBadgeCategory? category}) {
    if (category != null) {
      // Navigate to specific category
      context.go(fullBadgeListsPath, extra: category);
    } else {
      // Navigate to general badge list
      context.go(fullBadgeListsPath);
    }
  }
}

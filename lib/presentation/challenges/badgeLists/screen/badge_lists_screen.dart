// lib/presentation/challenges/badgeLists/screen/badge_lists_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/data/model/badge.dart' as model;

import '../../../../data/model/badge.dart';
import '../../provider/badge_lists_provider.dart';
import '../viewmodel/badge_lists_view_model.dart';
import '../widgets/category_badges_section.dart';

class BadgeListsScreen extends ConsumerStatefulWidget {
  final AchievementBadgeCategory? initialCategory;

  const BadgeListsScreen({super.key, this.initialCategory});

  @override
  ConsumerState<BadgeListsScreen> createState() => _BadgeListsScreenState();
}

class _BadgeListsScreenState extends ConsumerState<BadgeListsScreen> {
  bool _isRefreshing = false;

  Future<void> _refreshBadges() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
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
    final badgesState = ref.watch(badgeListsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.badge_list_title),
        actions: [
          if (_isRefreshing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshBadges,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshBadges,
        child: badgesState.when(
          loading: () => const _LoadingIndicator(),
          error: (error, stackTrace) => _ErrorDisplay(error: error, l10n: l10n),
          data: (badges) => _BadgeTabsView(
            initialCategory: widget.initialCategory,
            badges: badges,
            l10n: l10n,
          ),
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorDisplay extends StatelessWidget {
  final dynamic error;
  final AppLocalizations l10n;

  const _ErrorDisplay({required this.error, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(l10n.badge_error_loading(error)),
    );
  }
}

class _BadgeTabsView extends StatelessWidget {
  final AchievementBadgeCategory? initialCategory;
  final List<AchievementBadge> badges;
  final AppLocalizations l10n;

  const _BadgeTabsView({
    required this.initialCategory,
    required this.badges,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    // Only include the three specific categories
    final categories = [
      model.AchievementBadgeCategory.dailySteps,
      model.AchievementBadgeCategory.totalSteps,
      model.AchievementBadgeCategory.totalCyclingDistance,
    ];

    // Find initial tab index if initialCategory is provided
    int initialIndex = 0;
    if (initialCategory != null) {
      final idx = categories.indexOf(initialCategory!);
      if (idx >= 0) initialIndex = idx;
    }

    return DefaultTabController(
      length: categories.length,
      initialIndex: initialIndex,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            tabs: categories
                .map((category) => Tab(text: _getCategoryName(category, l10n)))
                .toList(),
          ),
          Expanded(
            child: TabBarView(
              children: categories
                  .map((category) => _buildCategoryTab(context, category, l10n))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(BuildContext context,
      model.AchievementBadgeCategory category, AppLocalizations l10n) {
    // Return specific widget based on category
    switch (category) {
      case model.AchievementBadgeCategory.dailySteps:
        return const DailyStepsWidget();
      case model.AchievementBadgeCategory.totalSteps:
        return const TotalStepsWidget();
      case model.AchievementBadgeCategory.totalCyclingDistance:
        return const CyclingWidget();
    }
  }

  String _getCategoryName(
      model.AchievementBadgeCategory category, AppLocalizations l10n) {
    switch (category) {
      case model.AchievementBadgeCategory.dailySteps:
        return l10n.badge_daily_steps_category;
      case model.AchievementBadgeCategory.totalSteps:
        return l10n.badge_total_steps_category;
      case model.AchievementBadgeCategory.totalCyclingDistance:
        return l10n.badge_cycling_category;
    }
  }
}

class DailyStepsWidget extends ConsumerWidget {
  const DailyStepsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final todayStepsAsync = ref.watch(todayStepsProvider);

    return todayStepsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text(l10n.common_error(error))),
      data: (todaySteps) => CategoryBadgesSection(
        category: AchievementBadgeCategory.dailySteps,
        currentValue: todaySteps,
      ),
    );
  }
}

class TotalStepsWidget extends ConsumerWidget {
  const TotalStepsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final totalStepsAsync = ref.watch(totalStepsProvider);

    return totalStepsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text(l10n.common_error(error))),
      data: (totalSteps) => CategoryBadgesSection(
        category: AchievementBadgeCategory.totalSteps,
        currentValue: totalSteps,
      ),
    );
  }
}

class CyclingWidget extends ConsumerWidget {
  const CyclingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final totalCyclingAsync = ref.watch(totalCyclingProvider);

    return totalCyclingAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text(l10n.common_error(error))),
      data: (totalCycling) => CategoryBadgesSection(
        category: AchievementBadgeCategory.totalCyclingDistance,
        currentValue: totalCycling,
      ),
    );
  }
}

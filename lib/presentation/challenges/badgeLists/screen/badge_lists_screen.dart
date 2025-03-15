// lib/presentation/challenges/badgeLists/screen/badge_lists_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movetopia/data/model/badge.dart' as model;
import 'package:movetopia/presentation/challenges/badgeLists/widgets/reset_badges_button.dart';

import '../../../../data/model/badge.dart';
import '../viewmodel/badge_lists_provider.dart';
import '../viewmodel/badge_lists_view_model.dart';
import '../widgets/category_badges_section.dart';

class BadgeListsScreen extends HookConsumerWidget {
  const BadgeListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final badgesState = ref.watch(badgeListsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.badge_list_title),
        actions: [
          const ResetBadgesButton(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(badgeListsViewModelProvider.notifier).refreshBadges();
            },
          ),
        ],
      ),
      body: badgesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(l10n.badge_error_loading(error)),
        ),
        data: (badges) {
          // Only include the three specific categories
          final categories = [
            model.AchivementBadgeCategory.dailySteps,
            model.AchivementBadgeCategory.totalSteps,
            model.AchivementBadgeCategory.totalCyclingDistance,
          ];

          return DefaultTabController(
            length: categories.length,
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  tabs: categories
                      .map((category) =>
                          Tab(text: _getCategoryName(category, l10n)))
                      .toList(),
                ),
                Expanded(
                  child: TabBarView(
                    children: categories
                        .map((category) =>
                            _buildCategoryTab(context, ref, category))
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryTab(BuildContext context, WidgetRef ref,
      model.AchivementBadgeCategory category) {
    // Return specific widget based on category
    switch (category) {
      case model.AchivementBadgeCategory.dailySteps:
        return const DailyStepsWidget();
      case model.AchivementBadgeCategory.totalSteps:
        return const TotalStepsWidget();
      case model.AchivementBadgeCategory.totalCyclingDistance:
        return const CyclingWidget();
    }
  }

  String _getCategoryName(model.AchivementBadgeCategory category, l10n) {
    switch (category) {
      case model.AchivementBadgeCategory.dailySteps:
        return l10n.badge_daily_steps_category;
      case model.AchivementBadgeCategory.totalSteps:
        return l10n.badge_total_steps_category;
      case model.AchivementBadgeCategory.totalCyclingDistance:
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
        category: AchivementBadgeCategory.dailySteps,
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
        category: AchivementBadgeCategory.totalSteps,
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
        category: AchivementBadgeCategory.totalCyclingDistance,
        currentValue: totalCycling,
      ),
    );
  }
}

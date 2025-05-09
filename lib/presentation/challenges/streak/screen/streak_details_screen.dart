import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../profile/debug_settings/provider/debug_provider.dart';
import '../../provider/streak_provider.dart';

// Provider für den Ladezustand des manuellen Refreshs
final manualRefreshLoadingProvider = StateProvider<bool>((ref) => false);

class StreakDetailsScreen extends ConsumerWidget {
  const StreakDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final completedDays = ref.watch(completedDaysProvider);
    final streakCount = ref.watch(streakCountProvider);

    // Key für den RefreshIndicator
    final refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

    // Farbe für Header und AppBar
    final headerColor =
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.streakDetails),
        scrolledUnderElevation: 0.0,
        backgroundColor: headerColor,
        elevation: 0,
        actions: [
          // Manueller Refresh-Button in der AppBar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Löse den Pull-to-Refresh aus
              refreshIndicatorKey.currentState?.show();
            },
            tooltip: 'Daten aktualisieren',
          ),
        ],
      ),
      body: completedDays.when(
        data: (days) => _buildContent(
          context,
          days,
          streakCount,
          l10n,
          ref,
          refreshIndicatorKey,
          headerColor,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<DateTime> days,
    AsyncValue<int> streakCount,
    AppLocalizations l10n,
    WidgetRef ref,
    GlobalKey<RefreshIndicatorState> refreshIndicatorKey,
    Color headerColor,
  ) {
    return RefreshIndicator(
      key: refreshIndicatorKey,
      onRefresh: () => _refreshData(context, ref),
      child: Column(
        children: [
          // Header mit Streak-Zähler
          _buildHeader(context, streakCount, ref, headerColor),

          // Kalender
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              // Wichtig für RefreshIndicator
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCalendar(context, days, l10n, ref),
                  const SizedBox(height: 24),
                  _buildLegend(context, l10n),
                  const SizedBox(height: 16),
                  _buildCompletedDaysText(context, days, l10n),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AsyncValue<int> streakCount,
      WidgetRef ref, Color headerColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: streakCount.when(
        data: (count) => Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStreakIcon(context, count, ref),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.streakCount(count),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              count > 0
                  ? AppLocalizations.of(context)!.streakMessage
                  : AppLocalizations.of(context)!.streakStart,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        loading: () => const CircularProgressIndicator(),
        error: (error, stack) => Text('Error: $error'),
      ),
    );
  }

  Widget _buildStreakIcon(
      BuildContext context, int streakCount, WidgetRef ref) {
    // Prüfe, ob heute erfüllt ist
    final completedDaysValue = ref.read(completedDaysProvider).value ?? [];
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final isTodayCompleted = completedDaysValue.any((day) =>
        day.year == normalizedToday.year &&
        day.month == normalizedToday.month &&
        day.day == normalizedToday.day);

    // Prüfe, ob Vortage erfüllt sind (Streak ist aktiv, aber heute fehlt noch)
    final yesterday = normalizedToday.subtract(const Duration(days: 1));
    final isYesterdayCompleted = completedDaysValue.any((day) =>
        day.year == yesterday.year &&
        day.month == yesterday.month &&
        day.day == yesterday.day);

    // Zeige Ausrufezeichen nur, wenn Streak aktiv ist (gestern erfüllt),
    // heute aber noch nicht erfüllt ist
    final showAlert =
        !isTodayCompleted && isYesterdayCompleted && streakCount > 0;

    // Widget-Stack mit Flamme und optionalem Ausrufezeichen
    return Stack(
      clipBehavior: Clip
          .none, // Erlaubt, dass Elemente außerhalb des Stacks platziert werden
      children: [
        // Basis-Flammen-Icon
        Icon(
          Icons.local_fire_department,
          color: Theme.of(context).colorScheme.primary,
          size: 32,
        ),

        // Ausrufezeichen, wenn nötig
        if (showAlert)
          Positioned(
            top: -8,
            right: -8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Text(
                '!',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCalendar(BuildContext context, List<DateTime> days,
      AppLocalizations l10n, WidgetRef ref) {
    final installDateAsyncValue = ref.watch(installationDateProvider);
    DateTime? installationDate;
    installDateAsyncValue.whenData((date) {
      installationDate = date;
    });

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: TableCalendar(
          firstDay: DateTime(2024, 1, 1),
          lastDay: DateTime.now(),
          focusedDay: DateTime.now(),
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          locale: Localizations.localeOf(context).toString(),
          calendarStyle: CalendarStyle(
            markersMaxCount: 1,
            markerSize: 8,
            markerDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            weekendTextStyle:
                TextStyle(color: Theme.of(context).colorScheme.error),
            holidayTextStyle:
                TextStyle(color: Theme.of(context).colorScheme.error),
            outsideTextStyle: TextStyle(color: Colors.grey.shade400),
            todayDecoration: BoxDecoration(
              color: days.any((d) =>
                      d.year == DateTime.now().year &&
                      d.month == DateTime.now().month &&
                      d.day == DateTime.now().day)
                  ? StreakColors.active // Lila nur bei erreichten Zielen
                  : Theme.of(context)
                      .colorScheme
                      .secondary
                      .withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ) ??
                const TextStyle(),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: Theme.of(context).colorScheme.primary,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            weekendStyle: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              final normalizedDay = DateTime(day.year, day.month, day.day);

              bool isBeforeInstallation = false;
              if (installationDate != null) {
                final normalizedInstallDate = DateTime(installationDate!.year,
                    installationDate!.month, installationDate!.day);

                if (normalizedDay.isBefore(normalizedInstallDate)) {
                  isBeforeInstallation = true;
                }
              }

              final isOutsideMonth = day.month != focusedDay.month;
              final isToday = normalizedDay.isToday;
              final isCompleted = normalizedDay.isCompletedIn(days);

              if (isToday && !isCompleted) {
                final yesterday =
                    normalizedDay.subtract(const Duration(days: 1));
                final isYesterdayCompleted = yesterday.isCompletedIn(days);

                if (isYesterdayCompleted &&
                    yesterday.getStreakColor(days) == StreakColors.active) {
                  return _buildTodayWithActiveStreakContainer(
                      context: context, day: day, isCompleted: false);
                }
              }

              if (isBeforeInstallation) {
                return Container(
                  margin: const EdgeInsets.all(4),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                );
              }

              // Normale Verarbeitung für Tage nach Installation
              final color = normalizedDay.getStreakColor(days);
              bool isActive = color == StreakColors.active;

              if (!isActive && isCompleted) {
                final prevDay = normalizedDay.subtract(const Duration(days: 1));
                final isPrevCompleted = prevDay.isCompletedIn(days);

                if (isPrevCompleted) {
                  final prevColor = prevDay.getStreakColor(days);
                  if (prevColor == StreakColors.active) {
                    isActive = true;
                  }
                }
              }

              Color effectiveColor = color;
              if (isOutsideMonth) {
                if (isActive || color == StreakColors.active) {
                  effectiveColor = StreakColors.active.withValues(alpha: 0.5);
                } else if (color == StreakColors.broken) {
                  effectiveColor = StreakColors.broken.withValues(alpha: 0.5);
                } else {
                  effectiveColor =
                      StreakColors.notCompleted.withValues(alpha: 0.3);
                }
              }

              final prevDay = normalizedDay.subtract(const Duration(days: 1));
              final nextDay = normalizedDay.add(const Duration(days: 1));
              final isPrevCompleted = prevDay.isCompletedIn(days);
              final isNextCompleted = nextDay.isCompletedIn(days);

              return Stack(
                children: [
                  if ((isActive || color == StreakColors.active) &&
                      isPrevCompleted)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Container(
                          height: 4,
                          width: 12,
                          color: isOutsideMonth
                              ? StreakColors.active.withValues(alpha: 0.5)
                              : StreakColors.active,
                        ),
                      ),
                    ),
                  if ((isActive || color == StreakColors.active) &&
                      isNextCompleted)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Container(
                          height: 4,
                          width: 12,
                          color: isOutsideMonth
                              ? StreakColors.active.withValues(alpha: 0.5)
                              : StreakColors.active,
                        ),
                      ),
                    ),
                  _buildDayContainer(
                      context: context,
                      day: day,
                      color: isActive ? StreakColors.active : effectiveColor,
                      isToday: isToday,
                      isCompleted: isCompleted,
                      isOutsideMonth: isOutsideMonth),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDayContainer({
    required BuildContext context,
    required DateTime day,
    required Color color,
    required bool isToday,
    required bool isCompleted,
    required bool isOutsideMonth,
  }) {
    if (isToday) {
      return Container(
        margin: const EdgeInsets.all(4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted
                  ? StreakColors.active
                  : Theme.of(context).colorScheme.secondary,
              width: 2,
            ),
            color: isCompleted
                ? StreakColors.active.withValues(alpha: 0.2)
                : Theme.of(context)
                    .colorScheme
                    .secondary
                    .withValues(alpha: 0.1),
          ),
          padding: const EdgeInsets.all(6),
          child: Text(
            '${day.day}',
            style: TextStyle(
              color: isCompleted
                  ? StreakColors.active
                  : Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    final opacityFactor = isOutsideMonth ? 0.7 : 1.0;
    final textOpacity = isOutsideMonth ? 0.8 : 1.0;

    return Container(
      margin: const EdgeInsets.all(4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isCompleted && !isOutsideMonth
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.3 * opacityFactor),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: color == StreakColors.notCompleted
              ? Colors.black.withValues(alpha: textOpacity)
              : Colors.white.withValues(alpha: textOpacity),
          fontWeight: isOutsideMonth ? FontWeight.normal : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTodayWithActiveStreakContainer({
    required BuildContext context,
    required DateTime day,
    required bool isCompleted,
  }) {
    return Container(
      margin: const EdgeInsets.all(4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: StreakColors.active.withValues(alpha: 0.7),
            width: 2,
          ),
          color: StreakColors.active.withValues(alpha: 0.1),
        ),
        padding: const EdgeInsets.all(6),
        child: Text(
          '${day.day}',
          style: const TextStyle(
            color: StreakColors.active,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context, AppLocalizations l10n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.streakLegend,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            // Aktive Streak-Erklärung
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: StreakColors.active,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.streakActive,
                        style: const TextStyle(
                          color: StreakColors.active,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.streakActiveDescription,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Unterbrochene Streak-Erklärung
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: StreakColors.broken,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.streakBroken,
                        style: const TextStyle(
                          color: StreakColors.broken,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.streakBrokenDescription,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Nicht abgeschlossene Tage-Erklärung
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: StreakColors.notCompleted,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.streakNotCompleted,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.streakNotCompletedDescription,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedDaysText(
      BuildContext context, List<DateTime> days, AppLocalizations l10n) {
    if (days.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.streakNoData,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Anzahl der Tage gruppiert nach Monat anzeigen
    final now = DateTime.now();
    final thisMonthDays = days
        .where((day) => day.year == now.year && day.month == now.month)
        .length;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              l10n.streakStats,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.streakMonthlyAchievement(thisMonthDays),
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.streakTotalDays(days.length),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshData(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      await ref.read(refreshStreakFromHealthDataProvider)();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.streakDataUpdated),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.streakUpdateError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

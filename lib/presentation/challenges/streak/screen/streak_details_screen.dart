import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../provider/streak_provider.dart';

class StreakDetailsScreen extends ConsumerWidget {
  const StreakDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final completedDays = ref.watch(completedDaysProvider);
    final streakCount = ref.watch(streakCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.streakDetails),
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        elevation: 0,
      ),
      body: completedDays.when(
        data: (days) => _buildContent(context, days, streakCount, l10n),
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

  Widget _buildContent(BuildContext context, List<DateTime> days,
      AsyncValue<int> streakCount, AppLocalizations l10n) {
    return Column(
      children: [
        // Header mit Streak-Zähler
        _buildHeader(context, streakCount, l10n),

        // Kalender
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildCalendar(context, days, l10n),
                const SizedBox(height: 24),
                _buildLegend(context, l10n),
                const SizedBox(height: 16),
                _buildCompletedDaysText(context, days, l10n),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, AsyncValue<int> streakCount,
      AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                Icon(
                  Icons.local_fire_department,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.streakCount(count),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              count > 0 ? l10n.streakMessage : l10n.streakStart,
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

  Widget _buildCalendar(
      BuildContext context, List<DateTime> days, AppLocalizations l10n) {
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
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
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
              final color = day.getStreakColor(days);

              // Nachbar-Tage prüfen für Verbindungen
              final prevDay = day.subtract(const Duration(days: 1));
              final nextDay = day.add(const Duration(days: 1));

              final isPrevCompleted = days.any((d) =>
                  d.year == prevDay.year &&
                  d.month == prevDay.month &&
                  d.day == prevDay.day);

              final isNextCompleted = days.any((d) =>
                  d.year == nextDay.year &&
                  d.month == nextDay.month &&
                  d.day == nextDay.day);

              final isCompleted = color != Colors.grey.shade300;

              return Stack(
                children: [
                  // Horizontale Verbindungslinien
                  if (isCompleted && isPrevCompleted)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Container(
                          height: 4,
                          width: 12,
                          color: color,
                        ),
                      ),
                    ),
                  if (isCompleted && isNextCompleted)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Container(
                          height: 4,
                          width: 12,
                          color: color,
                        ),
                      ),
                    ),

                  // Haupt-Container für den Tag
                  Container(
                    margin: const EdgeInsets.all(4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isCompleted
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: color == Colors.grey.shade300
                            ? Colors.black
                            : Colors.white,
                        fontWeight:
                            day.isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              );
            },
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
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFFAF52DE),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.streakActive,
                  style: TextStyle(
                    color: const Color(0xFFAF52DE),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.red.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.streakBroken,
                  style: TextStyle(
                    color: Colors.red.shade300,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.streakNotCompleted,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
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
}

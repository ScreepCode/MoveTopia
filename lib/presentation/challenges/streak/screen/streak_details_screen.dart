import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
        actions: [
          // Manueller Refresh-Button in der AppBar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _refreshData(context, ref);
            },
            tooltip: 'Daten aktualisieren',
          ),
        ],
      ),
      body: completedDays.when(
        data: (days) => _buildContent(context, days, streakCount, l10n, ref),
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

  Future<void> _refreshData(BuildContext context, WidgetRef ref) async {
    try {
      // Daten von Health neu laden
      await ref.read(refreshStreakFromHealthDataProvider)();

      // UI-Refresh wurde bereits im Provider ausgelöst

      // Optional: Bestätigung anzeigen
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Streak-Daten wurden mit Health-Daten aktualisiert'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Aktualisieren: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildContent(
    BuildContext context,
    List<DateTime> days,
    AsyncValue<int> streakCount,
    AppLocalizations l10n,
    WidgetRef ref,
  ) {
    return RefreshIndicator(
      onRefresh: () => _refreshData(context, ref),
      child: Column(
        children: [
          // Header mit Streak-Zähler
          _buildHeader(context, streakCount, ref),

          // Kalender
          Expanded(
            child: SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(), // Wichtig für RefreshIndicator
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
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, AsyncValue<int> streakCount, WidgetRef ref) {
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
              color: days.any((d) =>
                      d.year == DateTime.now().year &&
                      d.month == DateTime.now().month &&
                      d.day == DateTime.now().day)
                  ? const Color(
                      0xFFAF52DE) // Purple streak color when goal is met
                  : Theme.of(context).colorScheme.secondary.withOpacity(0.3),
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
              // Verwende die vereinfachte Streak-Logik
              final color = day.getStreakColor(days);
              final isToday = day.isToday;
              final isCompleted = day.isCompletedIn(days);

              // Berechne, ob Verbindungslinien angezeigt werden sollen
              final prevDay = day.subtract(const Duration(days: 1));
              final nextDay = day.add(const Duration(days: 1));
              final isPrevCompleted = prevDay.isCompletedIn(days);
              final isNextCompleted = nextDay.isCompletedIn(days);

              return Stack(
                children: [
                  // Horizontale Verbindungslinien, wenn benötigt
                  if (isCompleted && isPrevCompleted)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Container(
                          height: 4,
                          width: 12,
                          color: color, // Gleiche Farbe wie der Tag
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
                          color: color, // Gleiche Farbe wie der Tag
                        ),
                      ),
                    ),

                  // Haupt-Container für den Tag
                  _buildDayContainer(
                      context: context,
                      day: day,
                      color: color,
                      isToday: isToday,
                      isCompleted: isCompleted),
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
                        'Tage die Teil deiner aktuellen Streak sind (aufeinanderfolgende Tage bis heute/gestern)',
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
                        'Tage die du früher erreicht hast, aber nicht Teil deiner aktuellen Streak sind',
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
                        'Tage an denen du dein Schrittziel nicht erreicht hast',
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

  Widget _buildDayContainer({
    required BuildContext context,
    required DateTime day,
    required Color color,
    required bool isToday,
    required bool isCompleted,
  }) {
    // Wenn es der heutige Tag ist, spezielle Darstellung verwenden
    if (isToday) {
      return Container(
        margin: const EdgeInsets.all(4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // Transparenter Hintergrund für den heutigen Tag
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(100), // Immer rund für heute
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              // Lila Rand wenn erledigt, sonst die Standard-Farbe
              color: isCompleted
                  ? StreakColors.active
                  : Theme.of(context).colorScheme.secondary,
              width: 2,
            ),
            // Transparente Füllung in der entsprechenden Farbe
            color: isCompleted
                ? StreakColors.active.withOpacity(0.2)
                : Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ),
          padding: const EdgeInsets.all(6),
          child: Text(
            '${day.day}',
            style: TextStyle(
              // Textfarbe passend zum Rand
              color: isCompleted
                  ? StreakColors.active
                  : Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    // Standard-Darstellung für alle anderen Tage
    return Container(
      margin: const EdgeInsets.all(4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8), // Eckig für andere Tage
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
          color:
              color == StreakColors.notCompleted ? Colors.black : Colors.white,
          fontWeight: FontWeight.normal,
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

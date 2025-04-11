import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

// Assume normalizeData exists elsewhere or define a placeholder
// Example placeholder:
List<int> normalizeData(List<int> data, int length, int defaultValue) {
  if (data.length >= length) {
    return data.sublist(data.length - length);
  } else {
    return List.filled(length - data.length, defaultValue)..addAll(data);
  }
}

/// A custom painter for drawing a sleep line chart.
class SleepLinePainter extends CustomPainter {
  final List<int> sleepData;
  final double chartWidth;
  final double chartHeight;
  final double leftPadding;
  final double rightPadding;
  final double maxSleepHours;
  final Color lineColor;
  final Color fillColor;
  final Color dotColor;
  final Color todayLabelColor;
  final Color todayTextColor;

  SleepLinePainter({
    required this.sleepData,
    required this.chartWidth,
    required this.chartHeight,
    required this.leftPadding,
    required this.rightPadding,
    required this.maxSleepHours,
    required this.lineColor,
    required this.fillColor,
    required this.dotColor,
    required this.todayLabelColor,
    required this.todayTextColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!_validateParameters()) return;
    // Ensure there are exactly 7 data points after normalization for weekly view
    if (sleepData.isEmpty || sleepData.length != 7) return;

    final availableWidth = chartWidth - leftPadding - rightPadding;
    if (availableWidth <= 0) return;

    final barWidth = availableWidth / 7; // Width allocated per day

    final points = <Offset>[];
    final validIndices = <int>[];

    for (int i = 0; i < sleepData.length; i++) {
      // Skip days with no sleep data (0 or negative)
      if (sleepData[i] <= 0) continue;

      final sleepHours = sleepData[i] / 60.0;
      // Normalize sleep hours against the max *possible* sleep hours for y-axis scaling
      // Ensure maxSleepHours is not zero to avoid division by zero
      final normalizedSleepHours = maxSleepHours > 0
          ? (sleepHours / maxSleepHours).clamp(0.0, 1.0)
          : 0.0;

      // Calculate the center X position for the data point within its day slot
      final x = leftPadding + (i * barWidth) + (barWidth / 2);
      // Calculate Y position based on normalized sleep hours
      // Inverse relationship: higher value means lower y-coordinate
      final y = chartHeight - (normalizedSleepHours * chartHeight);

      // Ensure y is finite and within bounds
      if (y.isFinite && y >= 0 && y <= chartHeight) {
        points.add(Offset(x, y));
        validIndices
            .add(i); // Keep track of the original index for styling 'today'
      }
    }

    // Need at least two points to draw a line
    if (points.length < 2) return;

    _drawSleepLine(canvas, points, chartHeight);
    _drawDots(canvas, points, validIndices);
  }

  /// Validates the parameters to ensure they are within acceptable ranges.
  bool _validateParameters() {
    return chartWidth.isFinite &&
        chartWidth > 0 &&
        chartHeight.isFinite &&
        chartHeight > 0 &&
        leftPadding.isFinite &&
        leftPadding >= 0 &&
        rightPadding.isFinite &&
        rightPadding >= 0 &&
        maxSleepHours.isFinite &&
        maxSleepHours > 0;
  }

  /// Draws the sleep line and fills the area below it.
  void _drawSleepLine(Canvas canvas, List<Offset> points, double chartHeight) {
    final fillPath = Path();
    // Start fill from the bottom-left of the first point
    fillPath.moveTo(points.first.dx, chartHeight);
    fillPath.lineTo(
        points.first.dx, points.first.dy); // Move up to the first data point

    final linePath = Path();
    linePath.moveTo(points.first.dx,
        points.first.dy); // Start line from the first data point

    // Iterate through points to draw line segments and define fill area
    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];

      // Add line segment to the fill path
      fillPath.lineTo(next.dx, next.dy);

      // Use quadratic Bezier curves for a smoother line
      // Control point is midway between current and next x, at current y
      final controlPointX = (current.dx + next.dx) / 2;
      // Using current.dy as control point Y makes the curve start horizontally
      linePath.quadraticBezierTo(controlPointX, current.dy, next.dx, next.dy);
    }

    // Close the fill path by moving down to the bottom-right of the last point
    fillPath.lineTo(points.last.dx, chartHeight);
    fillPath.close(); // Connect back to the starting point (implicitly)

    // Draw the filled area
    canvas.drawPath(
        fillPath,
        Paint()
          ..color = fillColor // Use the specified fill color
          ..style = PaintingStyle.fill);

    // Draw the sleep line itself
    canvas.drawPath(
        linePath,
        Paint()
          ..color = lineColor // Use the specified line color
          ..strokeWidth = 3 // Line thickness
          ..style = PaintingStyle.stroke // Draw the path outline
          ..strokeCap = StrokeCap.round // Rounded line endings
          ..strokeJoin = StrokeJoin.round); // Rounded line joins
  }

  /// Draws the dots on the sleep line.
  void _drawDots(Canvas canvas, List<Offset> points, List<int> validIndices) {
    for (int i = 0; i < points.length; i++) {
      final index = validIndices[i]; // Get the original index (0-6)
      // Determine if the current point corresponds to 'today' (the last day in a 7-day view)
      final isToday = index == 6;
      final point = points[i];
      // Make 'today's' dot slightly larger
      final dotRadius = isToday ? 5.0 : 4.0;

      // Draw the dot
      canvas.drawCircle(point, dotRadius, Paint()..color = dotColor);
    }
  }

  @override
  bool shouldRepaint(covariant SleepLinePainter oldDelegate) =>
      oldDelegate.sleepData != sleepData ||
      oldDelegate.chartWidth != chartWidth ||
      oldDelegate.chartHeight != chartHeight ||
      oldDelegate.maxSleepHours != maxSleepHours ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.dotColor != dotColor; // Repaint if data or config changes
}

// --- WeeklyStepsChart Widget ---
class WeeklyStepsChart extends StatelessWidget {
  final List<int> stepsData;
  final List<int> sleepData;
  final int stepGoal;

  late final List<int> _validStepsData;
  late final List<int> _validSleepData;

  WeeklyStepsChart({
    super.key,
    required this.stepsData,
    required this.sleepData,
    required this.stepGoal,
  }) {
    // Validate data upon initialization
    _validStepsData = _validateData(stepsData);
    _validSleepData = _validateData(sleepData);
  }

  // Helper method to validate and normalize data (replace non-finite/negative with 0)
  List<int> _validateData(List<int> data) {
    return data
        .map((value) => value.isFinite && value >= 0 ? value : 0)
        .toList();
  }

  // Helper method to find the maximum value in a list
  int _findMaxValue(List<int> data) {
    if (data.isEmpty) return 0;
    // Use reduce for finding max, providing a safe initial value if needed
    return data.fold<int>(0, (maxVal, current) => math.max(maxVal, current));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Extracted: Chart Title and Legend
            _buildChartTitle(context),
            const SizedBox(height: 24),
            SizedBox(
              height: 220, // Fixed height for the chart area
              // Extracted: Error handling wrapper for the chart
              child: _buildSafeChart(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the title section of the chart including the legend.
  Widget _buildChartTitle(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Icon(
          Icons.bar_chart_rounded,
          color: theme.colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          l10n.weekly_steps_title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        // Sleep data legend
        Row(
          children: [
            Container(
              width: 12,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              l10n.common_health_data_sleep,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the chart safely, handling potential runtime errors.
  Widget _buildSafeChart(BuildContext context) {
    try {
      // Extracted: Core chart building logic
      return _buildCombinedChart(context);
    } catch (e, stackTrace) {
      // Log error for debugging
      print('Error building chart: $e\n$stackTrace');
      // Extracted: Error display widget
      return _buildErrorWidget(context);
    }
  }

  /// Builds the widget displayed when a chart error occurs.
  Widget _buildErrorWidget(BuildContext context) {
    return Center(
      child: Text(
        AppLocalizations.of(context)!.weekly_steps_chart_error,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
      ),
    );
  }

  /// Builds the combined Bar chart (Steps) and Line chart (Sleep) overlay.
  Widget _buildCombinedChart(BuildContext context) {
    // Ensure data lists have exactly 7 items for the weekly chart
    final normalizedStepsData = normalizeData(_validStepsData, 7, 0);
    final normalizedSleepData = normalizeData(_validSleepData, 7, 0);

    // Calculate maximum values needed for scaling axes
    final maxSteps = _findMaxValue(normalizedStepsData);
    // Ensure a minimum height for the Y-axis even if steps are 0
    final effectiveMaxSteps = math.max(maxSteps, 1000);
    // Add padding to the top of the Y-axis (20% higher than max steps or goal)
    final safeMaxY = math.max(effectiveMaxSteps, stepGoal) * 1.2;

    final maxSleepMinutes = _findMaxValue(normalizedSleepData);
    // Ensure a minimum height for the sleep axis (e.g., 8 hours)
    final maxSleepHours = maxSleepMinutes > 0 ? maxSleepMinutes / 60.0 : 0.0;
    final effectiveMaxSleepHours = math.max(maxSleepHours, 8.0);

    // Generate date labels for the last 7 days
    final now = DateTime.now();
    final weekdays = List.generate(
      7,
      (index) => now.subtract(Duration(days: 6 - index)),
    );

    return Stack(
      children: [
        // Bar Chart for Steps
        ClipRect(
          // Clip the bar chart to prevent overflow if needed
          child: BarChart(
            // Extracted: BarChartData configuration
            _buildBarChartData(context, normalizedStepsData, safeMaxY, weekdays,
                effectiveMaxSteps.toDouble(), effectiveMaxSleepHours),
          ),
        ),
        // Overlay for Sleep Line Chart
        // Extracted: Sleep line overlay widget
        _buildSleepOverlay(
            context, normalizedSleepData, effectiveMaxSleepHours),
      ],
    );
  }

  /// Builds the BarChartData configuration for the step chart.
  BarChartData _buildBarChartData(
      BuildContext context,
      List<int> normalizedStepsData,
      double safeMaxY,
      List<DateTime> weekdays,
      double effectiveMaxSteps, // Needed for right titles calculation
      double effectiveMaxSleepHours // Needed for right titles calculation
      ) {
    final theme = Theme.of(context);

    return BarChartData(
      alignment: BarChartAlignment.spaceEvenly,
      maxY: safeMaxY,
      minY: 0,
      borderData: FlBorderData(show: false),
      // Hide chart border
      groupsSpace: 12,
      // Spacing between bars
      // Extracted: Axis titles configuration
      titlesData: _buildTitlesData(context, weekdays, effectiveMaxSteps,
          effectiveMaxSleepHours, safeMaxY),
      // Extracted: Grid lines configuration
      gridData: _buildGridData(context, effectiveMaxSteps),
      // Extracted: Step goal line configuration
      extraLinesData: _buildExtraLinesData(context, stepGoal),
      // Extracted: Bar groups generation
      barGroups:
          _buildBarGroups(context, normalizedStepsData, stepGoal, safeMaxY),
    );
  }

  /// Builds the FlTitlesData for axis labels.
  FlTitlesData _buildTitlesData(
      BuildContext context,
      List<DateTime> weekdays,
      double effectiveMaxSteps,
      double effectiveMaxSleepHours,
      double safeMaxY // Pass safeMaxY for scaling right axis titles
      ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    const axisLabelStyle = TextStyle(fontSize: 10);
    final axisLabelColor =
        theme.colorScheme.onSurface.withAlpha(179); // 70% opacity
    final tertiaryAxisLabelColor =
        theme.colorScheme.tertiary.withAlpha(179); // 70% opacity

    return FlTitlesData(
      show: true,
      // Bottom Axis (Weekdays)
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 25, // Space below the chart for labels
          getTitlesWidget: (value, meta) =>
              _bottomTitleWidgets(context, value, meta, weekdays),
        ),
        axisNameSize: 16, // Not used if axisNameWidget is null
      ),
      // Left Axis (Steps)
      leftTitles: AxisTitles(
        axisNameWidget: Text(
          l10n.common_health_data_steps,
          style: axisLabelStyle.copyWith(color: axisLabelColor),
          textAlign: TextAlign.center,
        ),
        axisNameSize: 20,
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 25, // Space left of the chart for labels
          getTitlesWidget: (value, meta) =>
              _leftTitleWidgets(context, value, meta, safeMaxY),
        ),
      ),
      // Right Axis (Sleep Hours) - Scaled relative to left axis
      rightTitles: AxisTitles(
        axisNameWidget: Text(
          l10n.common_health_data_hours,
          style: axisLabelStyle.copyWith(color: tertiaryAxisLabelColor),
          textAlign: TextAlign.center,
        ),
        axisNameSize: 20,
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 25, // Space right of the chart for labels
          getTitlesWidget: (value, meta) => _rightTitleWidgets(
              context, value, meta, safeMaxY, effectiveMaxSleepHours),
        ),
      ),
      // Top Axis (Hidden)
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );
  }

  /// Helper for building bottom axis title widgets (Weekdays).
  Widget _bottomTitleWidgets(BuildContext context, double value, TitleMeta meta,
      List<DateTime> weekdays) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final index = value.toInt();

    if (index < 0 || index >= weekdays.length) return const SizedBox();

    final weekday = weekdays[index];
    final dateText = DateFormat('E', l10n.localeName).format(weekday);
    final isToday = index == 6; // Last element is today

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        dateText,
        style: TextStyle(
          color: isToday
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withAlpha(179), // 70% opacity
          fontSize: 12,
          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  /// Helper for building left axis title widgets (Steps).
  Widget _leftTitleWidgets(
      BuildContext context, double value, TitleMeta meta, double safeMaxY) {
    final theme = Theme.of(context);
    // Hide the zero label and labels too close to the top if they clutter
    if (value == 0 || value >= safeMaxY) return const SizedBox();

    // Format large numbers with "K" for thousands
    String formattedValue;
    if (value >= 1000) {
      formattedValue =
          '${(value / 1000).toStringAsFixed(value < 10000 ? 1 : 0)}K'; // Add decimal for < 10k
    } else {
      formattedValue = value.toInt().toString();
    }

    return Text(
      formattedValue,
      style: TextStyle(
        color: theme.colorScheme.onSurface.withAlpha(179), // 70% opacity
        fontSize: 10,
      ),
      textAlign: TextAlign.right, // Align text to the right edge
    );
  }

  /// Helper for building right axis title widgets (Sleep Hours).
  Widget _rightTitleWidgets(BuildContext context, double value, TitleMeta meta,
      double safeMaxY, double effectiveMaxSleepHours) {
    final theme = Theme.of(context);
    // Hide the zero label and labels too close to the top
    if (value == 0 || value >= safeMaxY) return const SizedBox();

    // Calculate corresponding sleep hours based on the Y-axis value (which represents steps)
    double sleepHours = 0.0;
    // Scale the current Y value (step value) proportionally to the sleep hours range
    if (safeMaxY > 0 && effectiveMaxSleepHours > 0) {
      sleepHours = (value / safeMaxY) * effectiveMaxSleepHours;
    }

    // Avoid displaying 0.0 if calculated sleep is negligible but value > 0
    if (sleepHours < 0.05) return const SizedBox();

    String formattedValue =
        sleepHours.toStringAsFixed(1); // Format to one decimal place

    return Text(
      formattedValue,
      style: TextStyle(
        color: theme.colorScheme.tertiary.withAlpha(179),
        // 70% opacity for sleep color
        fontSize: 10,
      ),
      textAlign: TextAlign.left, // Align text to the left edge
    );
  }

  /// Builds the FlGridData for the horizontal grid lines.
  FlGridData _buildGridData(BuildContext context, double effectiveMaxSteps) {
    final theme = Theme.of(context);
    // Adjust grid interval based on max steps for better readability
    final interval = effectiveMaxSteps > 5000 ? 2000.0 : 1000.0;

    return FlGridData(
      show: true,
      horizontalInterval: interval,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: theme.colorScheme.onSurface.withAlpha(26), // 10% opacity
          strokeWidth: 1,
          dashArray: [5, 5], // Dashed line style
        );
      },
      drawVerticalLine: false, // No vertical grid lines
    );
  }

  /// Builds the ExtraLinesData for the step goal indicator line.
  ExtraLinesData _buildExtraLinesData(BuildContext context, int stepGoal) {
    final theme = Theme.of(context);

    // Only show goal line if goal is positive
    if (stepGoal <= 0) {
      return const ExtraLinesData(); // Return empty data if no goal
    }

    return ExtraLinesData(
      horizontalLines: [
        HorizontalLine(
            y: stepGoal.toDouble(),
            color: theme.colorScheme.primary,
            strokeWidth: 1.5,
            dashArray: [5, 5],
            // Dashed line style
            label: HorizontalLineLabel(
                show: true,
                labelResolver: (_) =>
                    AppLocalizations.of(context)!.weekly_steps_goal(stepGoal),
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(right: 5, bottom: 2),
                style:
                    TextStyle(fontSize: 10, color: theme.colorScheme.primary))),
      ],
    );
  }

  /// Builds the list of BarChartGroupData representing each day's steps.
  List<BarChartGroupData> _buildBarGroups(BuildContext context,
      List<int> normalizedStepsData, int stepGoal, double safeMaxY) {
    final theme = Theme.of(context);

    return List.generate(
      normalizedStepsData.length,
      (index) {
        final steps = normalizedStepsData[index];
        final stepsValue = steps.toDouble();

        // Clamp bar height to avoid exceeding chart bounds slightly below max Y for visual clearance
        final maxAllowedY = safeMaxY * 0.98; // Clamp slightly below the max Y
        final safeStepsValue = stepsValue.clamp(0.0, maxAllowedY);

        return BarChartGroupData(
          x: index, // Represents the day index (0-6)
          barRods: [
            BarChartRodData(
              toY: safeStepsValue, // Height of the bar
              // Extracted: Bar color calculation logic
              color: _getBarColor(context, index, steps, stepGoal),
              width: 16, // Width of the bar
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Builds the sleep line overlay using CustomPaint.
  Widget _buildSleepOverlay(BuildContext context, List<int> normalizedSleepData,
      double effectiveMaxSleepHours) {
    final theme = Theme.of(context);

    // These padding values need to align the line chart points with the center of the bar chart bars.
    // They depend on axis label reserved sizes, bar width, and group spacing.
    // May require fine-tuning based on visual output.
    const double leftAxisReservedWidth = 40.0; // From leftTitles reservedSize
    const double rightAxisReservedWidth = 40.0; // From rightTitles reservedSize
    const double bottomAxisReservedHeight =
        25.0; // From bottomTitles reservedSize
    const double groupsSpace = 12.0; // From BarChartData
    const double barWidth = 16.0; // From BarChartRodData

    // Approximate calculation for horizontal padding:
    // Padding = AxisWidth + HalfGroupSpace + HalfBarWidth
    const double calculatedLeftPadding =
        leftAxisReservedWidth + (groupsSpace / 2) + (barWidth / 2);
    const double calculatedRightPadding =
        rightAxisReservedWidth + (groupsSpace / 2) + (barWidth / 2);

    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Subtract bottom padding for axis labels from available height
          final chartHeight = constraints.maxHeight - bottomAxisReservedHeight;
          final chartWidth = constraints.maxWidth;

          if (chartHeight <= 0 || chartWidth <= 0) {
            return const SizedBox(); // Avoid painting on zero size
          }

          return CustomPaint(
            painter: SleepLinePainter(
              sleepData: normalizedSleepData,
              chartWidth: chartWidth,
              chartHeight: chartHeight,
              // Use calculated padding for potentially better alignment
              leftPadding: calculatedLeftPadding,
              rightPadding: calculatedRightPadding,
              maxSleepHours: effectiveMaxSleepHours,
              lineColor: theme.colorScheme.tertiary,
              // Make fill slightly transparent
              fillColor: theme.colorScheme.tertiary.withAlpha(0),
              dotColor: theme.colorScheme.tertiary,
              // Pass theme colors for 'today' styling if needed inside painter
              todayLabelColor: theme.colorScheme.tertiaryContainer,
              todayTextColor: theme.colorScheme.onTertiaryContainer,
            ),
            child: Container(), // CustomPaint needs a child
          );
        },
      ),
    );
  }

  /// Determines the color of a bar based on its index (day) and step count vs goal.
  Color _getBarColor(BuildContext context, int index, int steps, int stepGoal) {
    final theme = Theme.of(context);
    final bool isToday = index == 6; // Last bar represents today
    final bool goalReached = stepGoal > 0 && steps >= stepGoal;

    if (isToday) {
      if (goalReached) {
        return theme.colorScheme.primary; // Goal reached today: primary color
      } else if (stepGoal > 0) {
        // Today, goal not reached: Interpolate color based on progress
        final progress = (steps / stepGoal).clamp(0.0, 1.0);
        // Transition from error-ish/low color through mid-opacity primary to full primary
        if (progress < 0.5) {
          // Lerp from a less saturated/error color to mid-opacity primary
          return Color.lerp(
            theme.colorScheme.errorContainer.withAlpha(179),
            // Example starting color
            theme.colorScheme.primary.withAlpha(179),
            // Target mid color (70% opacity)
            progress * 2, // Scale 0.0-0.5 to 0.0-1.0
          )!;
        } else {
          // Lerp from mid-opacity primary to full primary
          return Color.lerp(
            theme.colorScheme.primary.withAlpha(179), // Start from mid color
            theme.colorScheme.primary, // Target full primary color
            (progress - 0.5) * 2, // Scale 0.5-1.0 to 0.0-1.0
          )!;
        }
      } else {
        // Today, no goal set: Use a default less prominent color
        return theme.colorScheme.primary.withAlpha(179); // 70% opacity primary
      }
    } else {
      // Past days: Use less prominent colors
      if (goalReached) {
        return theme.colorScheme.primary
            .withAlpha(179); // Past day, goal reached: 70% opacity
      } else {
        return theme.colorScheme.primary
            .withAlpha(102); // Past day, goal not reached: 40% opacity
      }
    }
  }
}

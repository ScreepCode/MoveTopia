import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:movetopia/data/model/activity.dart';
import 'package:movetopia/data/model/heart_frequency_zones.dart';
import 'package:movetopia/presentation/activities/details/widget/graph_visualization.dart';

class HearthFrequencyGraph extends StatelessWidget {
  const HearthFrequencyGraph({
    super.key,
    required this.data,
    required this.activityStartTime,
    required this.activityEndTime,
  });

  final List<Data<int>> data;
  final DateTime activityStartTime;
  final DateTime activityEndTime;

  // Function to determine color based on y-value
  Color _getColorForValue(double value) {
    // Define thresholds for color changes
    return HeartFrequencyZone.fromBpm(value.toInt()).color;
  }

  LinearGradient _buildLinearGradient() {
    var colors = HeartFrequencyZone.values.map((e) => e.color).toList();
    // We need to check if the maximum values are lower than the steps
    // If so, we need to remove the last color
    // So if no value higher than 160 is present, we remove the red color
    // If no value higher than 140 is present, we remove the orange color
    // If no value higher than 120 is present, we remove the yellow color
    if (data.isNotEmpty) {
      var maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
      if (maxValue < 160) {
        colors.removeAt(4);
      }
      if (maxValue < 140) {
        colors.removeAt(3);
      }
      if (maxValue < 120) {
        colors.removeAt(2);
      }
    }
    // We also need to partition the colors
    // So if we have 3 colors, we need to set the stops to [0.0, 0.5, 1.0]
    // If we have 4 colors, we need to set the stops to [0.0, 0.33, 0.66, 1.0]
    // If we have 5 colors, we need to set the stops to [0.0, 0.25, 0.5, 0.75, 1.0]
    var stops = <double>[];
    for (int i = 0; i < colors.length; i++) {
      stops.add(i / (colors.length - 1));
    }

    return LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: colors,
      stops: stops,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GraphVisualization(
      xAxisLabel: l10n.activity_time,
      yAxisLabel: l10n.activity_heart_frequency,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          // Calculate color based on y-value
          Color dotColor = _getColorForValue(spot.y);
          return FlDotCirclePainter(
            radius: 1,
            color: dotColor,
            strokeWidth: 0,
            strokeColor: Colors.white,
          );
        },
      ),
      lineTouchData: LineTouchData(
          getTouchedSpotIndicator: (data, spot) {
            return spot.map((e) {
              return TouchedSpotIndicatorData(
                FlLine(
                  color: Theme.of(context).colorScheme.secondary,
                  strokeWidth: 2,
                ),
                FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: _getColorForValue(spot.y),
                      strokeWidth: 0,
                      strokeColor: Colors.white,
                    );
                  },
                ),
              );
            }).toList();
          },
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                return LineTooltipItem(
                  '${touchedSpot.y} bpm',
                  TextStyle(
                    color:
                        (touchedSpot.bar.color?.computeLuminance() ?? 0) > 0.5
                            ? Colors.black
                            : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                );
              }).toList();
            },
            getTooltipColor: (touchedSpot) => _getColorForValue(touchedSpot.y),
          )),
      data: data,
      activityStartTime: activityStartTime,
      activityEndTime: activityEndTime,
      title: l10n.activity_heart_frequency,
      barAreaData: BarAreaData(
        show: true,
        gradient: _buildLinearGradient(),
      ),
      gradientColors: HeartFrequencyZone.values.map((e) => e.color).toList(),
    );
  }
}

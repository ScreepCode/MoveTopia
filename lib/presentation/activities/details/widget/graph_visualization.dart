import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movetopia/data/model/activity.dart';
import 'package:movetopia/presentation/common/widgets/generic_card.dart';
import 'package:movetopia/utils/unit_utils.dart';

class GraphVisualization<T> extends StatelessWidget {
  GraphVisualization(
      {super.key,
      required this.data,
      required this.activityStartTime,
      required this.activityEndTime,
      required this.title,
      required this.dotData,
      required this.barAreaData,
      required this.lineTouchData,
      required this.xAxisLabel,
      required this.yAxisLabel,
      required this.gradientColors,
      this.checkToShowHorizontalLine});

  List<Data<T>> data;
  final String title;
  final List<Color> gradientColors;
  final String? xAxisLabel;
  final String? yAxisLabel;
  FlDotData dotData;
  DateTime activityStartTime;
  DateTime activityEndTime;
  bool Function(double value)? checkToShowHorizontalLine;
  LineTouchData lineTouchData;
  final BarAreaData barAreaData;

  @override
  Widget build(BuildContext context) {
    return GenericCard(
        title: title,
        content: Stack(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1.70,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 18,
                  left: 12,
                  bottom: 12,
                ),
                child: LineChart(
                  mainData(),
                ),
              ),
            ),
          ],
        ));
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    // If its the last value, we need to show the end time
    var milliseconds =
        (value * 1000).toInt() - activityStartTime.millisecondsSinceEpoch;
    // Round to a second
    milliseconds = (milliseconds / 1000).round() * 1000;

    var timeRange =
        timeRangePartitionTime(activityStartTime, activityEndTime, 4);
    if ((milliseconds) % timeRange != 0) {
      return const SizedBox();
    }
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    Widget text;
    var date = DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
    text = Text(
      DateFormat("HH:mm:ss").format(date),
      style: style,
    );

    return SideTitleWidget(
      meta: meta,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    String text = value % 20 == 0 ? value.toInt().toString() : '';

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  double getMinX(List<Data> data) {
    return (activityStartTime.millisecondsSinceEpoch / 1000).toDouble();
  }

  double getMaxX(List<Data> data) {
    return (activityEndTime.millisecondsSinceEpoch / 1000).toDouble();
  }

  double tryParse(String value) {
    try {
      return double.parse(value);
    } catch (e) {
      return 0;
    }
  }

  double getMaxY(List<Data> data) {
    double maxY = 0;
    for (var element in data) {
      if (element.value > maxY) {
        var value = tryParse(element.value.toString());
        maxY = value;
      }
    }

    return maxY + 20;
  }

  double getMinY(List<Data> data) {
    double minY = 200;
    for (var element in data) {
      if (element.value < minY) {
        var value = tryParse(element.value.toString());
        minY = value;
      }
    }

    return minY > 120 ? 80 : minY - 20;
  }

  List<FlSpot> getSpots(List<Data> data) {
    List<FlSpot> spots = [];
    data = data
        .where((e) =>
            e.startTime.isAfter(activityStartTime) &&
            e.endTime.isBefore(activityEndTime))
        .toList();
    for (var element in data) {
      var value = tryParse(element.value.toString());
      spots.add(FlSpot(
          (element.startTime.millisecondsSinceEpoch / 1000).toDouble(), value));
    }
    return spots;
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: false,
        horizontalInterval: 1,
        verticalInterval: 1,
        checkToShowHorizontalLine: (value) => checkToShowHorizontalLine != null
            ? checkToShowHorizontalLine!(value)
            : value % 20 == 0,
      ),
      lineTouchData: lineTouchData,
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          axisNameWidget: xAxisLabel != null
              ? Text(
                  xAxisLabel!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                )
              : null,
          axisNameSize: xAxisLabel != null ? 25 : 0,
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: Colors.grey.shade700,
          width: 1,
        ),
      ),
      minX: getMinX(data),
      maxX: getMaxX(data),
      minY: getMinY(data),
      maxY: getMaxY(data),
      lineBarsData: [
        LineChartBarData(
            spots: getSpots(data),
            isCurved: true,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: dotData,
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: gradientColors
                  .map((color) => color.withValues(alpha: 1))
                  .toList(),
            ),
            belowBarData: barAreaData),
      ],
    );
  }
}

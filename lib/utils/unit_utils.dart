import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

double metresToKilometres(int? metres) {
  var kilometres = metres != null ? (metres / 1000) : 0.0;
  // Round kilometres to 2 decimal places
  kilometres = (((kilometres * 100).toInt()) / 100).toDouble();
  return kilometres;
}

int timeRangePartitionTime(DateTime start, DateTime end, int partition) {
  // We need to check if the start and end are not null
  // We need to check if the start and end are not the same
  if (start == end) {
    return 0;
  }
  // We need to round the start and end to the nearest second
  var startMilliseconds = (start.millisecondsSinceEpoch / 1000).round() * 1000;
  var endMilliseconds = (end.millisecondsSinceEpoch / 1000).round() * 1000;

  // Then the time in milliseconds is the difference between the start and end
  // divided by the partition

  return ((endMilliseconds - startMilliseconds) / partition).toInt();
}

String getDuration(int minutes, BuildContext context) {
  int hours = minutes ~/ 60;
  int remainingMinutes = minutes % 60;
  if (hours > 1 && remainingMinutes > 1) {
    return AppLocalizations.of(context)!
        .activities_hours_minutes(hours, remainingMinutes);
  } else {
    String minutesText = remainingMinutes != 1
        ? AppLocalizations.of(context)!.activities_minutes(remainingMinutes)
        : AppLocalizations.of(context)!.activities_minute(remainingMinutes);
    if (hours == 0) return minutesText;
    String hoursText = "";
    if (hours > 0) {
      hoursText = hours != 1
          ? AppLocalizations.of(context)!.activities_hours(hours)
          : AppLocalizations.of(context)!.activities_hour(hours);
    }

    return "$hoursText $minutesText";
  }
}

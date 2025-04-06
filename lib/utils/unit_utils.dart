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

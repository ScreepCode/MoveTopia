// Class to represent a time range
class TimeRange {
  final DateTime start;
  final DateTime end;

  TimeRange(this.start, this.end);

  bool contains(DateTime dateTime) {
    return dateTime.isAfter(start.subtract(const Duration(seconds: 1))) &&
        dateTime.isBefore(end.add(const Duration(seconds: 1)));
  }

  bool containsRange(DateTime rangeStart, DateTime rangeEnd) {
    return contains(rangeStart) && contains(rangeEnd);
  }

  bool overlaps(DateTime rangeStart, DateTime rangeEnd) {
    return (rangeStart.isBefore(end) || rangeStart.isAtSameMomentAs(end)) &&
        (rangeEnd.isAfter(start) || rangeEnd.isAtSameMomentAs(start));
  }

  @override
  String toString() => 'TimeRange($start - $end)';
}

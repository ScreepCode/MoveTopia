double metresToKilometres(int? metres) {
  var kilometres = metres != null ? (metres / 1000) : 0.0;
  // Round kilometres to 2 decimal places
  kilometres = (((kilometres * 100).toInt()) / 100).toDouble();
  return kilometres;
}

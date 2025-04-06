import 'package:flutter/material.dart';

enum HeartFrequencyZone {
  light(60, 100, Colors.green),
  moderate(100, 120, Colors.lightGreen),
  cardio(120, 140, Colors.yellow),
  intense(140, 160, Colors.orange),
  peak(160, 220, Colors.red);

  final int lowerBound;
  final int upperBound;
  final Color color;

  const HeartFrequencyZone(this.lowerBound, this.upperBound, this.color);

  factory HeartFrequencyZone.fromBpm(int bpm) {
    for (var zone in HeartFrequencyZone.values) {
      if (bpm >= zone.lowerBound && bpm < zone.upperBound) {
        return zone;
      }
    }
    return HeartFrequencyZone.peak; // Default for very high values
  }
}

import 'package:flutter/material.dart';
import 'package:health/health.dart';

Map<HealthWorkoutActivityType, String> activityTypeTranslations(Locale locale) {
  switch (locale.languageCode) {
    case "en":
      return {
        HealthWorkoutActivityType.ARCHERY: "Archery",
        HealthWorkoutActivityType.BADMINTON: "Badminton",
        HealthWorkoutActivityType.BASEBALL: "Baseball",
        HealthWorkoutActivityType.BASKETBALL: "Basketball",
        HealthWorkoutActivityType.BIKING: "Biking",
        HealthWorkoutActivityType.BOXING: "Boxing",
        HealthWorkoutActivityType.CRICKET: "Cricket",
        HealthWorkoutActivityType.CURLING: "Curling",
        HealthWorkoutActivityType.ELLIPTICAL: "Elliptical",
        HealthWorkoutActivityType.FENCING: "Fencing",
        HealthWorkoutActivityType.AMERICAN_FOOTBALL: "American football",
        HealthWorkoutActivityType.AUSTRALIAN_FOOTBALL: "Australian football",
        HealthWorkoutActivityType.SOCCER: "Soccer",
        HealthWorkoutActivityType.GOLF: "Golf",
        HealthWorkoutActivityType.GYMNASTICS: "Gymnastics",
        HealthWorkoutActivityType.HANDBALL: "Handball",
        HealthWorkoutActivityType.HIGH_INTENSITY_INTERVAL_TRAINING:
            "High intensity interval training",
        HealthWorkoutActivityType.HIKING: "Hiking",
        HealthWorkoutActivityType.HOCKEY: "Hockey",
        HealthWorkoutActivityType.SKATING: "Skating",
        HealthWorkoutActivityType.JUMP_ROPE: "Jump rope",
        HealthWorkoutActivityType.KICKBOXING: "Kickboxing",
        HealthWorkoutActivityType.MARTIAL_ARTS: "Martial arts",
        HealthWorkoutActivityType.PILATES: "Pilates",
        HealthWorkoutActivityType.RACQUETBALL: "Racquetball",
        HealthWorkoutActivityType.ROWING: "Rowing",
        HealthWorkoutActivityType.RUGBY: "Rugby",
        HealthWorkoutActivityType.RUNNING: "Running",
        HealthWorkoutActivityType.SAILING: "Sailing",
        HealthWorkoutActivityType.CROSS_COUNTRY_SKIING: "Cross country skiing",
        HealthWorkoutActivityType.DOWNHILL_SKIING: "Downhill skiing",
        HealthWorkoutActivityType.SNOWBOARDING: "Snowboarding",
        HealthWorkoutActivityType.SOFTBALL: "Softball",
        HealthWorkoutActivityType.SQUASH: "Squash",
        HealthWorkoutActivityType.STAIR_CLIMBING: "Stair climbing",
        HealthWorkoutActivityType.SWIMMING: "Swimming",
        HealthWorkoutActivityType.TABLE_TENNIS: "Table tennis",
        HealthWorkoutActivityType.TENNIS: "Tennis",
        HealthWorkoutActivityType.VOLLEYBALL: "Volleyball",
        HealthWorkoutActivityType.WALKING: "Walking",
        HealthWorkoutActivityType.WATER_POLO: "Water polo",
        HealthWorkoutActivityType.YOGA: "Yoga",
        HealthWorkoutActivityType.BOWLING: "Bowling",
        HealthWorkoutActivityType.CROSS_TRAINING: "Cross training",
        HealthWorkoutActivityType.TRACK_AND_FIELD: "Track and field",
        HealthWorkoutActivityType.DISC_SPORTS: "Disc sports",
        HealthWorkoutActivityType.LACROSSE: "Lacrosse",
        HealthWorkoutActivityType.PREPARATION_AND_RECOVERY:
            "Preparation and recovery",
        HealthWorkoutActivityType.FLEXIBILITY: "Flexibility",
        HealthWorkoutActivityType.COOLDOWN: "Cooldown",
        HealthWorkoutActivityType.WHEELCHAIR_WALK_PACE: "Wheelchair walk pace",
        HealthWorkoutActivityType.WHEELCHAIR_RUN_PACE: "Wheelchair run pace",
        HealthWorkoutActivityType.HAND_CYCLING: "Hand cycling",
        HealthWorkoutActivityType.CORE_TRAINING: "Core training",
        HealthWorkoutActivityType.FUNCTIONAL_STRENGTH_TRAINING:
            "Functional strength training",
        HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING:
            "Traditional strength training",
        HealthWorkoutActivityType.MIXED_CARDIO: "Mixed cardio",
        HealthWorkoutActivityType.STAIRS: "Stairs",
        HealthWorkoutActivityType.STEP_TRAINING: "Step training",
        HealthWorkoutActivityType.FITNESS_GAMING: "Fitness gaming",
        HealthWorkoutActivityType.BARRE: "Barre",
        HealthWorkoutActivityType.CARDIO_DANCE: "Cardio dance",
        HealthWorkoutActivityType.SOCIAL_DANCE: "Social dance",
        HealthWorkoutActivityType.MIND_AND_BODY: "Mind and body",
        HealthWorkoutActivityType.PICKLEBALL: "Pickleball",
        HealthWorkoutActivityType.CLIMBING: "Climbing",
        HealthWorkoutActivityType.EQUESTRIAN_SPORTS: "Equestrian sports",
        HealthWorkoutActivityType.FISHING: "Fishing",
        HealthWorkoutActivityType.HUNTING: "Hunting",
        HealthWorkoutActivityType.PLAY: "Play",
        HealthWorkoutActivityType.SNOW_SPORTS: "Snow sports",
        HealthWorkoutActivityType.PADDLE_SPORTS: "Paddle sports",
        HealthWorkoutActivityType.WATER_FITNESS: "Water fitness",
        HealthWorkoutActivityType.WATER_SPORTS: "Water sports",
        HealthWorkoutActivityType.TAI_CHI: "Tai chi",
        HealthWorkoutActivityType.WRESTLING: "Wrestling",
        HealthWorkoutActivityType.BIKING_STATIONARY: "Biking stationary",
        HealthWorkoutActivityType.CALISTHENICS: "Calisthenics",
        HealthWorkoutActivityType.DANCING: "Dancing",
        HealthWorkoutActivityType.FRISBEE_DISC: "Frisbee disc",
        HealthWorkoutActivityType.GUIDED_BREATHING: "Guided breathing",
        HealthWorkoutActivityType.ICE_SKATING: "Ice skating",
        HealthWorkoutActivityType.PARAGLIDING: "Paragliding",
        HealthWorkoutActivityType.ROCK_CLIMBING: "Rock climbing",
        HealthWorkoutActivityType.ROWING_MACHINE: "Rowing machine",
        HealthWorkoutActivityType.RUNNING_TREADMILL: "Running treadmill",
        HealthWorkoutActivityType.SCUBA_DIVING: "Scuba diving",
        HealthWorkoutActivityType.SKIING: "Skiing",
        HealthWorkoutActivityType.SNOWSHOEING: "Snowshoeing",
        HealthWorkoutActivityType.STAIR_CLIMBING_MACHINE:
            "Stair climbing machine",
        HealthWorkoutActivityType.STRENGTH_TRAINING: "Strength training",
        HealthWorkoutActivityType.SURFING: "Surfing",
        HealthWorkoutActivityType.SWIMMING_OPEN_WATER: "Swimming open water",
        HealthWorkoutActivityType.SWIMMING_POOL: "Swimming pool",
        HealthWorkoutActivityType.WALKING_TREADMILL: "Walking treadmill",
        HealthWorkoutActivityType.WEIGHTLIFTING: "Weightlifting",
        HealthWorkoutActivityType.WHEELCHAIR: "Wheelchair",
        HealthWorkoutActivityType.OTHER: "Other",
      };
    case "de":
      return {
        HealthWorkoutActivityType.BADMINTON: "Badminton",
        HealthWorkoutActivityType.BASEBALL: "Baseball",
        HealthWorkoutActivityType.BASKETBALL: "Basketball",
        HealthWorkoutActivityType.BIKING: "Radfahren",
        HealthWorkoutActivityType.BOXING: "Boxen",
        HealthWorkoutActivityType.CRICKET: "Cricket",
        HealthWorkoutActivityType.CURLING: "Curling",
        HealthWorkoutActivityType.ELLIPTICAL: "Crosstrainer",
        HealthWorkoutActivityType.FENCING: "Fechten",
        HealthWorkoutActivityType.AMERICAN_FOOTBALL: "American Football",
        HealthWorkoutActivityType.AUSTRALIAN_FOOTBALL: "Australischer Fussball",
        HealthWorkoutActivityType.SOCCER: "Fussball",
        HealthWorkoutActivityType.GOLF: "Golf",
        HealthWorkoutActivityType.GYMNASTICS: "Turnen",
        HealthWorkoutActivityType.HANDBALL: "Handball",
        HealthWorkoutActivityType.HIGH_INTENSITY_INTERVAL_TRAINING:
            "Hochintensives Intervalltraining (HIIT)",
        HealthWorkoutActivityType.HIKING: "Wandern",
        HealthWorkoutActivityType.HOCKEY: "Hockey",
        HealthWorkoutActivityType.SKATING: "Skaten",
        HealthWorkoutActivityType.JUMP_ROPE: "Springseil",
        HealthWorkoutActivityType.KICKBOXING: "Kickboxen",
        HealthWorkoutActivityType.MARTIAL_ARTS: "Kampfsportarten",
        HealthWorkoutActivityType.PILATES: "Pilates",
        HealthWorkoutActivityType.RACQUETBALL: "Racquetball",
        HealthWorkoutActivityType.ROWING: "Rudern",
        HealthWorkoutActivityType.RUGBY: "Rugby",
        HealthWorkoutActivityType.RUNNING: "Laufen",
        HealthWorkoutActivityType.SAILING: "Segeln",
        HealthWorkoutActivityType.CROSS_COUNTRY_SKIING: "Langlauf",
        HealthWorkoutActivityType.DOWNHILL_SKIING: "Alpinski",
        HealthWorkoutActivityType.SNOWBOARDING: "Snowboarden",
        HealthWorkoutActivityType.SOFTBALL: "Softball",
        HealthWorkoutActivityType.SQUASH: "Squash",
        HealthWorkoutActivityType.STAIR_CLIMBING: "Treppen steigen",
        HealthWorkoutActivityType.SWIMMING: "Schwimmen",
        HealthWorkoutActivityType.TABLE_TENNIS: "Tischtennis",
        HealthWorkoutActivityType.TENNIS: "Tennis",
        HealthWorkoutActivityType.VOLLEYBALL: "Volleyball",
        HealthWorkoutActivityType.WALKING: "Spazierengehen",
        HealthWorkoutActivityType.WATER_POLO: "Wasserball",
        HealthWorkoutActivityType.YOGA: "Yoga",
        HealthWorkoutActivityType.BOWLING: "Bowling",
        HealthWorkoutActivityType.CROSS_TRAINING: "Crosstraining",
        HealthWorkoutActivityType.TRACK_AND_FIELD: "Leichtathletik",
        HealthWorkoutActivityType.DISC_SPORTS: "Discsportarten",
        HealthWorkoutActivityType.LACROSSE: "Lacrosse",
        HealthWorkoutActivityType.PREPARATION_AND_RECOVERY:
            "Vorbereitung und Erholung",
        HealthWorkoutActivityType.FLEXIBILITY: "Flexibilität",
        HealthWorkoutActivityType.COOLDOWN: "Cooldown",
        HealthWorkoutActivityType.WHEELCHAIR_WALK_PACE:
            "Rollstuhl-Gehgeschwindigkeit",
        HealthWorkoutActivityType.WHEELCHAIR_RUN_PACE:
            "Rollstuhl-Laufgeschwindigkeit",
        HealthWorkoutActivityType.HAND_CYCLING: "Handbike",
        HealthWorkoutActivityType.CORE_TRAINING: "Core-Training",
        HealthWorkoutActivityType.FUNCTIONAL_STRENGTH_TRAINING:
            "Funktionelles Krafttraining",
        HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING:
            "Traditionelles Krafttraining",
        HealthWorkoutActivityType.MIXED_CARDIO: "Gemischtes Cardio",
        HealthWorkoutActivityType.STAIRS: "Treppen",
        HealthWorkoutActivityType.STEP_TRAINING: "Step-Training",
        HealthWorkoutActivityType.FITNESS_GAMING: "Fitness-Gaming",
        HealthWorkoutActivityType.BARRE: "Barre",
        HealthWorkoutActivityType.CARDIO_DANCE: "Cardio-Dance",
        HealthWorkoutActivityType.SOCIAL_DANCE: "Gesellschaftstanz",
        HealthWorkoutActivityType.MIND_AND_BODY: "Körper und Geist",
        HealthWorkoutActivityType.PICKLEBALL: "Pickleball",
        HealthWorkoutActivityType.CLIMBING: "Klettern",
        HealthWorkoutActivityType.EQUESTRIAN_SPORTS: "Reitsport",
        HealthWorkoutActivityType.FISHING: "Angeln",
        HealthWorkoutActivityType.HUNTING: "Jagen",
        HealthWorkoutActivityType.PLAY: "Spielen",
        HealthWorkoutActivityType.SNOW_SPORTS: "Schneesportarten",
        HealthWorkoutActivityType.PADDLE_SPORTS: "Paddelsportarten",
        HealthWorkoutActivityType.WATER_FITNESS: "Wasserfitness",
        HealthWorkoutActivityType.WATER_SPORTS: "Wassersportarten",
        HealthWorkoutActivityType.TAI_CHI: "Tai Chi",
        HealthWorkoutActivityType.WRESTLING: "Ringen",
        HealthWorkoutActivityType.BIKING_STATIONARY: "Stationäres Radfahren",
        HealthWorkoutActivityType.CALISTHENICS: "Körpergewichtsübungen",
        HealthWorkoutActivityType.DANCING: "Tanzen",
        HealthWorkoutActivityType.FRISBEE_DISC: "Frisbee",
        HealthWorkoutActivityType.GUIDED_BREATHING: "Gezielte Atmung",
        HealthWorkoutActivityType.ICE_SKATING: "Eislaufen",
        HealthWorkoutActivityType.PARAGLIDING: "Paragleiten",
        HealthWorkoutActivityType.ROCK_CLIMBING: "Klettern",
        HealthWorkoutActivityType.ROWING_MACHINE: "Rudergerät",
        HealthWorkoutActivityType.RUNNING_TREADMILL: "Laufband",
        HealthWorkoutActivityType.SCUBA_DIVING: "Tauchen",
        HealthWorkoutActivityType.SKIING: "Skifahren",
        HealthWorkoutActivityType.SNOWSHOEING: "Schneeschuhwandern",
        HealthWorkoutActivityType.STAIR_CLIMBING_MACHINE: "Treppen-Stepper",
        HealthWorkoutActivityType.STRENGTH_TRAINING: "Krafttraining",
        HealthWorkoutActivityType.SURFING: "Surfen",
        HealthWorkoutActivityType.SWIMMING_OPEN_WATER:
            "Schwimmen im Freiwasser",
        HealthWorkoutActivityType.SWIMMING_POOL: "Schwimmen im Pool",
        HealthWorkoutActivityType.WALKING_TREADMILL: "Laufband-Walking",
        HealthWorkoutActivityType.WEIGHTLIFTING: "Gewichtheben",
        HealthWorkoutActivityType.WHEELCHAIR: "Rollstuhl",
        HealthWorkoutActivityType.OTHER: "Andere",
      };
    default:
      return {HealthWorkoutActivityType.OTHER: "Andere"};
  }
}

String getTranslatedActivityType(
    Locale locale, HealthWorkoutActivityType type) {
  return activityTypeTranslations(locale)[type] ??
      "Fail"; // "Fail" als Fallback
}

IconData getActivityIcon(HealthWorkoutActivityType type) {
  switch (type) {
    // Gymnastic/Dance
    case HealthWorkoutActivityType.FLEXIBILITY ||
          HealthWorkoutActivityType.BARRE ||
          HealthWorkoutActivityType.CARDIO_DANCE ||
          HealthWorkoutActivityType.SOCIAL_DANCE ||
          HealthWorkoutActivityType.DANCING ||
          HealthWorkoutActivityType.GYMNASTICS ||
          HealthWorkoutActivityType.PILATES:
      return Icons.sports_gymnastics;
    // Football
    case HealthWorkoutActivityType.AMERICAN_FOOTBALL ||
          HealthWorkoutActivityType.AUSTRALIAN_FOOTBALL ||
          HealthWorkoutActivityType.RUGBY:
      return Icons.sports_football_outlined;
    // Skiing etc.
    case HealthWorkoutActivityType.CROSS_COUNTRY_SKIING ||
          HealthWorkoutActivityType.DOWNHILL_SKIING ||
          HealthWorkoutActivityType.SNOW_SPORTS ||
          HealthWorkoutActivityType.SNOWBOARDING ||
          HealthWorkoutActivityType.SKIING:
      return Icons.downhill_skiing_outlined;
    // Biking
    case HealthWorkoutActivityType.BIKING ||
          HealthWorkoutActivityType.BIKING_STATIONARY:
      return Icons.directions_bike_outlined;
    // Running/Walking
    case HealthWorkoutActivityType.RUNNING ||
          HealthWorkoutActivityType.RUNNING_TREADMILL ||
          HealthWorkoutActivityType.WALKING ||
          HealthWorkoutActivityType.WALKING_TREADMILL ||
          HealthWorkoutActivityType.ELLIPTICAL ||
          HealthWorkoutActivityType.STEP_TRAINING:
      return Icons.directions_walk_outlined;
    // Tennis/Badminton
    case HealthWorkoutActivityType.TENNIS ||
          HealthWorkoutActivityType.BADMINTON ||
          HealthWorkoutActivityType.SQUASH ||
          HealthWorkoutActivityType.TABLE_TENNIS:
      return Icons.sports_tennis_outlined;
    // Fitness
    case HealthWorkoutActivityType.CALISTHENICS ||
          HealthWorkoutActivityType.CORE_TRAINING ||
          HealthWorkoutActivityType.CROSS_TRAINING ||
          HealthWorkoutActivityType.FUNCTIONAL_STRENGTH_TRAINING ||
          HealthWorkoutActivityType.WEIGHTLIFTING ||
          HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING ||
          HealthWorkoutActivityType.HIGH_INTENSITY_INTERVAL_TRAINING ||
          HealthWorkoutActivityType.STRENGTH_TRAINING ||
          HealthWorkoutActivityType.STAIR_CLIMBING_MACHINE ||
          HealthWorkoutActivityType.STAIR_CLIMBING ||
          HealthWorkoutActivityType.STAIRS ||
          HealthWorkoutActivityType.MIXED_CARDIO ||
          HealthWorkoutActivityType.JUMP_ROPE ||
          HealthWorkoutActivityType.TRACK_AND_FIELD:
      return Icons.fitness_center_outlined;
    // Swimming
    case HealthWorkoutActivityType.SWIMMING_POOL ||
          HealthWorkoutActivityType.SWIMMING_OPEN_WATER ||
          HealthWorkoutActivityType.SWIMMING ||
          HealthWorkoutActivityType.WATER_FITNESS ||
          HealthWorkoutActivityType.WATER_POLO ||
          HealthWorkoutActivityType.WATER_SPORTS:
      return Icons.pool;
    // Wheelchair
    case HealthWorkoutActivityType.WHEELCHAIR_WALK_PACE ||
          HealthWorkoutActivityType.WHEELCHAIR ||
          HealthWorkoutActivityType.WHEELCHAIR_RUN_PACE:
      return Icons.accessible;
    // Yoga/Cooldown
    case HealthWorkoutActivityType.COOLDOWN ||
          HealthWorkoutActivityType.YOGA ||
          HealthWorkoutActivityType.MIND_AND_BODY ||
          HealthWorkoutActivityType.PREPARATION_AND_RECOVERY:
      return Icons.self_improvement;
    // Volleyball
    case HealthWorkoutActivityType.VOLLEYBALL:
      return Icons.sports_volleyball;
    // MMA
    case HealthWorkoutActivityType.KICKBOXING ||
          HealthWorkoutActivityType.MARTIAL_ARTS ||
          HealthWorkoutActivityType.TAI_CHI:
      return Icons.sports_martial_arts;
    // Surfing
    case HealthWorkoutActivityType.SURFING:
      return Icons.surfing;
    // Skating
    case HealthWorkoutActivityType.SKATING:
      return Icons.skateboarding;
    // Specific
    case HealthWorkoutActivityType.BASEBALL:
      return Icons.sports_baseball_outlined;
    case HealthWorkoutActivityType.BASKETBALL:
      return Icons.sports_basketball;
    case HealthWorkoutActivityType.CRICKET:
      return Icons.sports_cricket_outlined;
    case HealthWorkoutActivityType.HANDBALL:
      return Icons.sports_handball_outlined;
    case HealthWorkoutActivityType.HOCKEY:
      return Icons.sports_hockey_outlined;
    case HealthWorkoutActivityType.SCUBA_DIVING:
      return Icons.scuba_diving_outlined;
    case HealthWorkoutActivityType.GOLF:
      return Icons.golf_course;
    case HealthWorkoutActivityType.HIKING:
      return Icons.hiking;
    case HealthWorkoutActivityType.SOCCER:
      return Icons.sports_soccer;
    case HealthWorkoutActivityType.ICE_SKATING:
      return Icons.ice_skating;
    case HealthWorkoutActivityType.ROWING ||
          HealthWorkoutActivityType.ROWING_MACHINE:
      return Icons.rowing;
    case HealthWorkoutActivityType.SAILING:
      return Icons.sailing;

    // The REST
    case HealthWorkoutActivityType.OTHER ||
          HealthWorkoutActivityType.CLIMBING ||
          HealthWorkoutActivityType.ARCHERY ||
          HealthWorkoutActivityType.BOWLING ||
          HealthWorkoutActivityType.BOXING ||
          HealthWorkoutActivityType.WRESTLING ||
          HealthWorkoutActivityType.CURLING ||
          HealthWorkoutActivityType.DISC_SPORTS ||
          HealthWorkoutActivityType.SOFTBALL ||
          HealthWorkoutActivityType.EQUESTRIAN_SPORTS ||
          HealthWorkoutActivityType.FENCING ||
          HealthWorkoutActivityType.HAND_CYCLING ||
          HealthWorkoutActivityType.LACROSSE ||
          HealthWorkoutActivityType.PADDLE_SPORTS ||
          HealthWorkoutActivityType.PARAGLIDING ||
          HealthWorkoutActivityType.PICKLEBALL ||
          HealthWorkoutActivityType.ROCK_CLIMBING ||
          HealthWorkoutActivityType.RACQUETBALL:
      return Icons.sports;
    default:
      Icons.abc;
  }
  return Icons.abc;
}

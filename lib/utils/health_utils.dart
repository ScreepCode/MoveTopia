import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:health/health.dart';

Map<HealthWorkoutActivityType, String> activityTypeTranslations(
    BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return {
    HealthWorkoutActivityType.ARCHERY: l10n.activity_type_archery,
    HealthWorkoutActivityType.BADMINTON: l10n.activity_type_badminton,
    HealthWorkoutActivityType.BASEBALL: l10n.activity_type_baseball,
    HealthWorkoutActivityType.BASKETBALL: l10n.activity_type_basketball,
    HealthWorkoutActivityType.BIKING: l10n.activity_type_biking,
    HealthWorkoutActivityType.BOXING: l10n.activity_type_boxing,
    HealthWorkoutActivityType.CRICKET: l10n.activity_type_cricket,
    HealthWorkoutActivityType.CURLING: l10n.activity_type_curling,
    HealthWorkoutActivityType.ELLIPTICAL: l10n.activity_type_elliptical,
    HealthWorkoutActivityType.FENCING: l10n.activity_type_fencing,
    HealthWorkoutActivityType.AMERICAN_FOOTBALL:
        l10n.activity_type_american_football,
    HealthWorkoutActivityType.AUSTRALIAN_FOOTBALL:
        l10n.activity_type_australian_football,
    HealthWorkoutActivityType.SOCCER: l10n.activity_type_soccer,
    HealthWorkoutActivityType.GOLF: l10n.activity_type_golf,
    HealthWorkoutActivityType.GYMNASTICS: l10n.activity_type_gymnastics,
    HealthWorkoutActivityType.HANDBALL: l10n.activity_type_handball,
    HealthWorkoutActivityType.HIGH_INTENSITY_INTERVAL_TRAINING:
        l10n.activity_type_hiit,
    HealthWorkoutActivityType.HIKING: l10n.activity_type_hiking,
    HealthWorkoutActivityType.HOCKEY: l10n.activity_type_hockey,
    HealthWorkoutActivityType.SKATING: l10n.activity_type_skating,
    HealthWorkoutActivityType.JUMP_ROPE: l10n.activity_type_jump_rope,
    HealthWorkoutActivityType.KICKBOXING: l10n.activity_type_kickboxing,
    HealthWorkoutActivityType.MARTIAL_ARTS: l10n.activity_type_martial_arts,
    HealthWorkoutActivityType.PILATES: l10n.activity_type_pilates,
    HealthWorkoutActivityType.RACQUETBALL: l10n.activity_type_racquetball,
    HealthWorkoutActivityType.ROWING: l10n.activity_type_rowing,
    HealthWorkoutActivityType.RUGBY: l10n.activity_type_rugby,
    HealthWorkoutActivityType.RUNNING: l10n.activity_type_running,
    HealthWorkoutActivityType.SAILING: l10n.activity_type_sailing,
    HealthWorkoutActivityType.CROSS_COUNTRY_SKIING:
        l10n.activity_type_cross_country_skiing,
    HealthWorkoutActivityType.DOWNHILL_SKIING:
        l10n.activity_type_downhill_skiing,
    HealthWorkoutActivityType.SNOWBOARDING: l10n.activity_type_snowboarding,
    HealthWorkoutActivityType.SOFTBALL: l10n.activity_type_softball,
    HealthWorkoutActivityType.SQUASH: l10n.activity_type_squash,
    HealthWorkoutActivityType.STAIR_CLIMBING: l10n.activity_type_stair_climbing,
    HealthWorkoutActivityType.SWIMMING: l10n.activity_type_swimming,
    HealthWorkoutActivityType.TABLE_TENNIS: l10n.activity_type_table_tennis,
    HealthWorkoutActivityType.TENNIS: l10n.activity_type_tennis,
    HealthWorkoutActivityType.VOLLEYBALL: l10n.activity_type_volleyball,
    HealthWorkoutActivityType.WALKING: l10n.activity_type_walking,
    HealthWorkoutActivityType.WATER_POLO: l10n.activity_type_water_polo,
    HealthWorkoutActivityType.YOGA: l10n.activity_type_yoga,
    HealthWorkoutActivityType.BOWLING: l10n.activity_type_bowling,
    HealthWorkoutActivityType.CROSS_TRAINING: l10n.activity_type_cross_training,
    HealthWorkoutActivityType.TRACK_AND_FIELD:
        l10n.activity_type_track_and_field,
    HealthWorkoutActivityType.DISC_SPORTS: l10n.activity_type_disc_sports,
    HealthWorkoutActivityType.LACROSSE: l10n.activity_type_lacrosse,
    HealthWorkoutActivityType.PREPARATION_AND_RECOVERY:
        l10n.activity_type_preparation_and_recovery,
    HealthWorkoutActivityType.FLEXIBILITY: l10n.activity_type_flexibility,
    HealthWorkoutActivityType.COOLDOWN: l10n.activity_type_cooldown,
    HealthWorkoutActivityType.WHEELCHAIR_WALK_PACE:
        l10n.activity_type_wheelchair_walk_pace,
    HealthWorkoutActivityType.WHEELCHAIR_RUN_PACE:
        l10n.activity_type_wheelchair_run_pace,
    HealthWorkoutActivityType.HAND_CYCLING: l10n.activity_type_hand_cycling,
    HealthWorkoutActivityType.CORE_TRAINING: l10n.activity_type_core_training,
    HealthWorkoutActivityType.FUNCTIONAL_STRENGTH_TRAINING:
        l10n.activity_type_functional_strength_training,
    HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING:
        l10n.activity_type_traditional_strength_training,
    HealthWorkoutActivityType.MIXED_CARDIO: l10n.activity_type_mixed_cardio,
    HealthWorkoutActivityType.STAIRS: l10n.activity_type_stairs,
    HealthWorkoutActivityType.STEP_TRAINING: l10n.activity_type_step_training,
    HealthWorkoutActivityType.FITNESS_GAMING: l10n.activity_type_fitness_gaming,
    HealthWorkoutActivityType.BARRE: l10n.activity_type_barre,
    HealthWorkoutActivityType.CARDIO_DANCE: l10n.activity_type_cardio_dance,
    HealthWorkoutActivityType.SOCIAL_DANCE: l10n.activity_type_social_dance,
    HealthWorkoutActivityType.MIND_AND_BODY: l10n.activity_type_mind_and_body,
    HealthWorkoutActivityType.PICKLEBALL: l10n.activity_type_pickleball,
    HealthWorkoutActivityType.CLIMBING: l10n.activity_type_climbing,
    HealthWorkoutActivityType.EQUESTRIAN_SPORTS:
        l10n.activity_type_equestrian_sports,
    HealthWorkoutActivityType.FISHING: l10n.activity_type_fishing,
    HealthWorkoutActivityType.HUNTING: l10n.activity_type_hunting,
    HealthWorkoutActivityType.PLAY: l10n.activity_type_play,
    HealthWorkoutActivityType.SNOW_SPORTS: l10n.activity_type_snow_sports,
    HealthWorkoutActivityType.PADDLE_SPORTS: l10n.activity_type_paddle_sports,
    HealthWorkoutActivityType.WATER_FITNESS: l10n.activity_type_water_fitness,
    HealthWorkoutActivityType.WATER_SPORTS: l10n.activity_type_water_sports,
    HealthWorkoutActivityType.TAI_CHI: l10n.activity_type_tai_chi,
    HealthWorkoutActivityType.WRESTLING: l10n.activity_type_wrestling,
    HealthWorkoutActivityType.BIKING_STATIONARY:
        l10n.activity_type_biking_stationary,
    HealthWorkoutActivityType.CALISTHENICS: l10n.activity_type_calisthenics,
    HealthWorkoutActivityType.DANCING: l10n.activity_type_dancing,
    HealthWorkoutActivityType.FRISBEE_DISC: l10n.activity_type_frisbee_disc,
    HealthWorkoutActivityType.GUIDED_BREATHING:
        l10n.activity_type_guided_breathing,
    HealthWorkoutActivityType.ICE_SKATING: l10n.activity_type_ice_skating,
    HealthWorkoutActivityType.PARAGLIDING: l10n.activity_type_paragliding,
    HealthWorkoutActivityType.ROCK_CLIMBING: l10n.activity_type_rock_climbing,
    HealthWorkoutActivityType.ROWING_MACHINE: l10n.activity_type_rowing_machine,
    HealthWorkoutActivityType.RUNNING_TREADMILL:
        l10n.activity_type_running_treadmill,
    HealthWorkoutActivityType.SCUBA_DIVING: l10n.activity_type_scuba_diving,
    HealthWorkoutActivityType.SKIING: l10n.activity_type_skiing,
    HealthWorkoutActivityType.SNOWSHOEING: l10n.activity_type_snowshoeing,
    HealthWorkoutActivityType.STAIR_CLIMBING_MACHINE:
        l10n.activity_type_stair_climbing_machine,
    HealthWorkoutActivityType.STRENGTH_TRAINING:
        l10n.activity_type_strength_training,
    HealthWorkoutActivityType.SURFING: l10n.activity_type_surfing,
    HealthWorkoutActivityType.SWIMMING_OPEN_WATER:
        l10n.activity_type_swimming_open_water,
    HealthWorkoutActivityType.SWIMMING_POOL: l10n.activity_type_swimming_pool,
    HealthWorkoutActivityType.WALKING_TREADMILL:
        l10n.activity_type_walking_treadmill,
    HealthWorkoutActivityType.WEIGHTLIFTING: l10n.activity_type_weightlifting,
    HealthWorkoutActivityType.WHEELCHAIR: l10n.activity_type_wheelchair,
    HealthWorkoutActivityType.OTHER: l10n.activity_type_other,
  };
}

String getTranslatedActivityType(
    BuildContext context, HealthWorkoutActivityType type) {
  return activityTypeTranslations(context)[type] ??
      AppLocalizations.of(context)!
          .activity_type_other; // Fallback to "Other" translated string
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

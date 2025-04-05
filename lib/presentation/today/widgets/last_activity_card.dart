import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:movetopia/data/model/activity.dart';
import 'package:movetopia/presentation/activities/routes.dart';
import 'package:movetopia/presentation/common/widgets/generic_card.dart';
import 'package:movetopia/utils/health_utils.dart';

class LastActivityCard extends StatelessWidget {
  const LastActivityCard({
    super.key,
    required this.lastActivity,
  });

  final ActivityPreview lastActivity;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(activitiesDetailsFullPath, extra: lastActivity),
      child: GenericCard(
        title: getTranslatedActivityType(context, lastActivity.activityType),
        subtitles: [(AppLocalizations.of(context)!.activity_last_activity)],
        iconData: getActivityIcon(lastActivity.activityType),
        color: Colors.lightGreen,
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${AppLocalizations.of(context)!.activity_duration}: ${(lastActivity.getDuration() / 60).toStringAsFixed(0)}min   ${lastActivity.caloriesBurnt} kcal",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

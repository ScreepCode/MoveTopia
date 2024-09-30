import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:movetopia/data/model/activity.dart';
import 'package:movetopia/utils/health_utils.dart';

class LastActivityCard extends StatelessWidget {
  const LastActivityCard({
    super.key,
    required this.lastActivity,
  });

  final ActivityPreview lastActivity;

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Theme.of(context).colorScheme.surface,
        child: GestureDetector(
            onTap: () =>
                context.push("/activities/details", extra: lastActivity),
            child: Column(
              children: [
                SafeArea(
                    minimum: const EdgeInsets.fromLTRB(20, 24.0, 20, 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${AppLocalizations.of(context)!.last_activity} - ${getTranslatedActivityType(Localizations.localeOf(context), lastActivity.activityType)}",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Row(children: [
                          Text(
                              "${AppLocalizations.of(context)!.duration}: ${lastActivity.getDuration()}min"),
                          Text(" ${lastActivity.caloriesBurnt} kcal")
                        ]),
                      ],
                    )),
                SizedBox(
                  height: 150,
                  child: Container(
                      decoration: const BoxDecoration(
                          color: Colors.lightGreen,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12))),
                      child: const Center(
                        child: Icon(
                          Icons.map,
                          size: 80,
                        ),
                      )),
                )
              ],
            )));
  }
}

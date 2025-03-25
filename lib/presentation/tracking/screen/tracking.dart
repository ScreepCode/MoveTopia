import 'package:activity_tracking/model/activity_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:movetopia/presentation/tracking/view_model/tracking_view_model.dart';

class TrackingScreen extends HookConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingState = ref.watch(trackingViewModelProvider);

    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.tracking_title),
    ),
      body: Column(children: [
        FilledButton(onPressed: () {
          ref.read(trackingViewModelProvider.notifier).startTracking(ActivityType.walking);
        }, child: Text("Start Walking")),
        Text(trackingState?.activity?.activityType?.name ?? "No activity"),
        Text(trackingState?.activity?.steps?.toString() ?? "0"),
        Text(trackingState?.activity?.distance?.toString() ?? "0"),
      ],)
    );

  }

}
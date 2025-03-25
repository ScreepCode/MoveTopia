import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TrackingScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.tracking_title),
    ),
      body: const Column(children: [
        Text("Hello World")
      ],)
    );

  }

}
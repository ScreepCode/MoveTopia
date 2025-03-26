import 'package:activity_tracking/model/activity_type.dart';
import 'package:flutter/material.dart';
import 'package:movetopia/presentation/tracking/widgets/activity_button.dart';

class StartActivity extends StatelessWidget{
  final Function onStart;

  const StartActivity({Key? key, required this.onStart}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(child:
          Column(mainAxisAlignment: MainAxisAlignment.center,children: [
            const Center(
              child: Text("Start your Activity", style: TextStyle(fontSize: 20),),
            ),
            _buildTrackingButtons(context, (activityType) => () => onStart(activityType),)

          ],)
      ,);
  }


  Widget _buildTrackingButtons(BuildContext context, Function onPressed) {
    final types = List.empty(growable: true);
    types.addAll(ActivityType.values);
    types.remove(ActivityType.unknown);

    return Row(mainAxisAlignment: MainAxisAlignment.center,children: types.map((e) => _buildActivityItem(context, e, onPressed )).toList(),);
  }

  Widget _buildActivityItem(BuildContext context, ActivityType activityType, Function onPressed) {
    return ActivityButton(activityType: activityType, onPressed: onPressed);
  }

}


import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'obj/ScheduleObj.dart';

class Schedule extends StatelessWidget {
  final ScheduleObj schedule;
  final ValueChanged<ScheduleObj> onScheduleChanged;

  Schedule({
    Key key,
    @required this.schedule,
    @required this.onScheduleChanged
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(

    );
  }
}
